//
//  Job+Core.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation
import SpeedsterCore
import Fluent
import GitHubKit


extension Row where Model == Job {
    
    func update(from job: SpeedsterCore.Job) {
        self.name = job.name
        self.nodeLabels = job.nodeLabels
        self.gitHub = job.gitHub
        self.environment = job.environment
        self.dockerDependendencies = job.dockerDependendencies
        self.disabled = 0
        self.speedsterFile = job
    }
    
}


extension SpeedsterCore.Job {
    
    fileprivate func update(phases dbWorkflow: Row<SpeedsterApi.Workflow>, coreWorkflow: SpeedsterCore.Job.Workflow, info: SpeedsterFileInfo, github: Github, on db: Database) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        
        func addTo(futures phases: [Workflow.Phase], stage: SpeedsterApi.Phase.Stage) {
            var x = phases.count
            for p in phases {
                let phase = SpeedsterApi.Phase.row(
                    from: p,
                    workflow: dbWorkflow,
                    order: x,
                    stage: stage
                )
                if phase.command.prefix(5) == "file:" {
                    let path = phase.command.replacingOccurrences(of: "file:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    do {
                        let future: EventLoopFuture<Void> = try GitHubKit.File.query(on: github).get(
                            org: info.org,
                            repo: info.repo,
                            path: path
                            ).download(on: github).flatMap { file in
                                phase.command = file.asString()
                                return phase.save(on: db)
                        }
                        futures.append(future)
                    } catch {
                        futures.append(db.eventLoop.makeFailedFuture(error))
                    }
                } else {
                    let future = phase.save(on: db)
                    futures.append(future)
                }
                x -= 1
            }
        }
        
        addTo(futures: coreWorkflow.preBuild, stage: .pre)
        addTo(futures: coreWorkflow.build, stage: .build)
        addTo(futures: coreWorkflow.postBuild, stage: .post)
        
        return futures.flatten(on: db.eventLoop)
    }
    
    func update(jobChildren job: Row<SpeedsterApi.Job>, info: SpeedsterFileInfo, github: Github, on db: Database) -> EventLoopFuture<Void> {
        return SpeedsterApi.Workflow.query(on: db).filter(\SpeedsterApi.Workflow.jobId == job.id).delete().flatMap {
            return Phase.query(on: db).filter(\Phase.jobId == job.id).delete().flatMap {
                var futures: [EventLoopFuture<Void>] = []
                for w in self.workflows {
                    let workflow = SpeedsterApi.Workflow.row(from: w, job: job)
                    let future = workflow.save(on: db).flatMap { _ in
                        return self.update(phases: workflow, coreWorkflow: w, info: info, github: github, on: db)
                    }
                    futures.append(future)
                }
                return futures.flatten(on: db.eventLoop)
            }
        }
    }
    
    func save(on db: Database) -> EventLoopFuture<Row<Job>> {
        let job = Job.row()
        job.update(from: self)
        job.disabled = 0
        return job.save(on: db).map { _ in
            return job
        }
    }
    
    fileprivate func updateJob(_ info: SpeedsterFileInfo, on db: Database) -> EventLoopFuture<Row<Job>> {
        return Job
            .query(on: db)
            .join(\GitHubJob.jobId, to: \Job.id)
            .filter(\GitHubJob.organization == info.org)
            .filter(\GitHubJob.repo == info.repo)
            .first().flatMap { job in
                guard let job = job else {
                    let job = Job.row()
                    job.update(from: self)
                    job.disabled = info.disabled ? 1 : 0
                    return job.save(on: db).flatMap { _ in
                        let githubJob = GitHubJob.row()
                        githubJob.repo = info.repo
                        githubJob.organization = info.org
                        githubJob.jobId = job.id
                        return githubJob.save(on: db).map { _ in
                            return job
                        }
                    }
                }
                job.update(from: self)
                job.disabled = info.disabled ? 1 : 0
                return job.update(on: db).map { _ in
                    return job
                }
        }
    }
    
    func saveOnDb(_ info: SpeedsterFileInfo, github: Github, on db: Database) -> EventLoopFuture<Void> {
        return updateJob(info, on: db).flatMap { job in
            return self.update(jobChildren: job, info: info, github: github, on: db).map { _ in
                return Void()
            }
        }
    }
    
}
