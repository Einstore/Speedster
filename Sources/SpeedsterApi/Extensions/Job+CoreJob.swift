//
//  Job+CoreJob.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation
import SpeedsterCore
import Fluent


extension Row where Model == Job {
    
    public func coreJob(on db: Database) -> EventLoopFuture<SpeedsterCore.Job> {
        return Workflow.query(on: db).filter(\Workflow.jobId == self.id).all().map { workflows in
            let job = SpeedsterCore.Job(
                name: self.name,
                repoUrl: self.repoUrl,
                // TODO: Map workflows properly!!!!
                workflows: []
            )
            return job
            
        }
    }
    
    func update(from job: SpeedsterCore.Job) {
        self.name = job.name
        self.repoUrl = job.repoUrl
        self.disabled = false
        self.speedsterFile = job
    }
    
}


extension SpeedsterCore.Job {
    
    fileprivate func update(phases db: Database, workflow: Row<SpeedsterApi.Workflow>) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        
        for w in workflows {
            func addTo(futures phases: [Workflow.Phase], stage: SpeedsterApi.Phase.Stage) {
                var x = phases.count
                for p in phases {
                    let phase = SpeedsterApi.Phase.row(
                        from: p,
                        workflow: workflow,
                        order: x,
                        stage: stage
                    )
                    let future = phase.save(on: db)
                    futures.append(future)
                    x -= 1
                }
            }
            
            addTo(futures: w.preBuild, stage: .pre)
            addTo(futures: w.build, stage: .build)
            addTo(futures: w.postBuild, stage: .post)
        }
        
        return futures.flatten(on: db.eventLoop)
    }
    
    fileprivate func update(workflows db: Database, job: Row<Job>) -> EventLoopFuture<[Row<SpeedsterApi.Workflow>]> {
        return SpeedsterApi.Workflow.query(on: db).filter(\SpeedsterApi.Workflow.jobId == job.id).delete().flatMap {
            var futures: [EventLoopFuture<Row<SpeedsterApi.Workflow>>] = []
            for w in self.workflows {
                let workflow = SpeedsterApi.Workflow.row(from: w, job: job)
                let future = workflow.save(on: db).map { workflow }
                futures.append(future)
            }
            return futures.flatten(on: db.eventLoop)
        }
    }
    
    fileprivate func updateJob(_ info: SpeedsterFileInfo, on db: Database) -> EventLoopFuture<Row<Job>> {
        let githubRepo = "\(info.org)/\(info.repo)"
        return Job
            .query(on: db)
            .filter(\Job.managed == Job.Managed.github)
            .filter(\Job.githubRepo == githubRepo)
            .first().flatMap { job in
                guard let job = job else {
                    let job = Job.row()
                    job.githubRepo = githubRepo
                    job.managed = Job.Managed.github
                    job.update(from: self)
                    job.disabled = info.disabled
                    return job.save(on: db).map { _ in
                        return job
                    }
                }
                job.update(from: self)
                job.disabled = info.disabled
                return job.update(on: db).map { _ in
                    return job
                }
        }
    }
    
    func saveOnDb(_ info: SpeedsterFileInfo, on db: Database) -> EventLoopFuture<Void> {
        return updateJob(info, on: db).flatMap { job in
            return self.update(workflows: db, job: job).flatMap { workflows in
                var futures: [EventLoopFuture<Void>] = []
                for workflow in workflows {
                    let future = self.update(phases: db, workflow: workflow)
                    futures.append(future)
                }
                return futures.flatten(on: db.eventLoop).map { _ in
                    return Void()
                }
            }
        }
    }
    
}
