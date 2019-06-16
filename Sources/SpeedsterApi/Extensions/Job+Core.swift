//
//  Job+Core.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation
import SpeedsterCore
import Fluent
import GithubAPI


extension Row where Model == Job {
    
    func update(from job: SpeedsterCore.Job) {
        self.name = job.name
        self.gitHubBuild = job.gitHub
        self.disabled = 0
        self.speedsterFile = job
    }
    
}


extension SpeedsterCore.Job {
    
    fileprivate func update(phases system: System, dbWorkflow: Row<SpeedsterApi.Workflow>, coreWorkflow: SpeedsterCore.Job.Workflow, info: SpeedsterFileInfo) -> EventLoopFuture<Void> {
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
                if phase.command.contains("file:") {
                    let path = phase.command.replacingOccurrences(of: "file:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let future: EventLoopFuture<Void> = try! GithubAPI.File.query(on: system.container).get(
                        organization: info.org,
                        repo: info.repo,
                        path: path
                        ).download(on: system.container).flatMap { file in
                            phase.command = file.asString()
                            return phase.save(on: system.db)
                    }
                    futures.append(future)
                } else {
                    let future = phase.save(on: system.db)
                    futures.append(future)
                }
                x -= 1
            }
        }
        
        addTo(futures: coreWorkflow.preBuild, stage: .pre)
        addTo(futures: coreWorkflow.build, stage: .build)
        addTo(futures: coreWorkflow.postBuild, stage: .post)
        
        return futures.flatten(on: system.db.eventLoop)
    }
    
    fileprivate func update(workflows system: System, job: Row<SpeedsterApi.Job>, info: SpeedsterFileInfo) -> EventLoopFuture<Void> {
        return SpeedsterApi.Workflow.query(on: system.db).filter(\SpeedsterApi.Workflow.jobId == job.id).delete().flatMap {
            return Phase.query(on: system.db).filter(\Phase.jobId == job.id).delete().flatMap {
                var futures: [EventLoopFuture<Void>] = []
                for w in self.workflows {
                    let workflow = SpeedsterApi.Workflow.row(from: w, job: job)
                    let future = workflow.save(on: system.db).flatMap { _ in
                        return self.update(phases: system, dbWorkflow: workflow, coreWorkflow: w, info: info)
                    }
                    futures.append(future)
                }
                return futures.flatten(on: system.db.eventLoop)
            }
        }
    }
    
    fileprivate func updateJob(_ info: SpeedsterFileInfo, on system: System) -> EventLoopFuture<Row<Job>> {
        return Job
            .query(on: system.db)
            .filter(\Job.managed == Job.Managed.github)
            .filter(\Job.githubRepo == info.repo)
            .filter(\Job.githubOrg == info.org)
            .first().flatMap { job in
                guard let job = job else {
                    let job = Job.row()
                    job.githubRepo = info.repo
                    job.githubOrg = info.org
                    job.managed = Job.Managed.github
                    job.update(from: self)
                    job.disabled = info.disabled ? 1 : 0
                    return job.save(on: system.db).map { _ in
                        return job
                    }
                }
                job.update(from: self)
                job.disabled = info.disabled ? 1 : 0
                return job.update(on: system.db).map { _ in
                    return job
                }
        }
    }
    
    func saveOnDb(_ info: SpeedsterFileInfo, on system: System) -> EventLoopFuture<Void> {
        return updateJob(info, on: system).flatMap { job in
            return self.update(workflows: system, job: job, info: info).map { _ in
                return Void()
            }
        }
    }
    
}
