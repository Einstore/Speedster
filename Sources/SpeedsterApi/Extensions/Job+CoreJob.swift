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
        self.disabled = 0
        self.speedsterFile = job
    }
    
}


extension SpeedsterCore.Job {
    
    fileprivate func update(phases db: Database, dbWorkflow: Row<SpeedsterApi.Workflow>, coreWorkflow: SpeedsterCore.Job.Workflow) -> EventLoopFuture<Void> {
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
                let future = phase.save(on: db)
                futures.append(future)
                x -= 1
            }
        }
        
        addTo(futures: coreWorkflow.preBuild, stage: .pre)
        addTo(futures: coreWorkflow.build, stage: .build)
        addTo(futures: coreWorkflow.postBuild, stage: .post)
        
        return futures.flatten(on: db.eventLoop)
    }
    
    fileprivate func update(workflows db: Database, job: Row<Job>) -> EventLoopFuture<Void> {
        return SpeedsterApi.Workflow.query(on: db).filter(\SpeedsterApi.Workflow.jobId == job.id).delete().flatMap {
            return Phase.query(on: db).filter(\Phase.jobId == job.id).delete().flatMap {
                var futures: [EventLoopFuture<Void>] = []
                for w in self.workflows {
                    let workflow = SpeedsterApi.Workflow.row(from: w, job: job)
                    let future = workflow.save(on: db).flatMap { _ in
                        return self.update(phases: db, dbWorkflow: workflow, coreWorkflow: w)
                    }
                    futures.append(future)
                }
                return futures.flatten(on: db.eventLoop)
            }
        }
    }
    
    fileprivate func updateJob(_ info: SpeedsterFileInfo, on db: Database) -> EventLoopFuture<Row<Job>> {
        return Job
            .query(on: db)
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
                    return job.save(on: db).map { _ in
                        return job
                    }
                }
                job.update(from: self)
                job.disabled = info.disabled ? 1 : 0
                return job.update(on: db).map { _ in
                    return job
                }
        }
    }
    
    func saveOnDb(_ info: SpeedsterFileInfo, on db: Database) -> EventLoopFuture<Void> {
        return updateJob(info, on: db).flatMap { job in
            return self.update(workflows: db, job: job).map { _ in
                return Void()
            }
        }
    }
    
}
