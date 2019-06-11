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
        let job = SpeedsterCore.Job(
            name: self.name,
            timeout: self.timeout,
            timeoutOnInactivity: self.timeoutOnInactivity,
            preBuild: [],
            build: [],
            postBuild: []
        )
        return db.eventLoop.makeSucceededFuture(job)
    }
    
    func update(from job: SpeedsterCore.Job) {
        self.name = job.name
        self.disabled = false
        self.speedsterFile = job
        self.repoUrl = job.repoUrl
        self.timeout = job.timeout
        self.timeoutOnInactivity = job.timeoutOnInactivity
    }
    
}


extension SpeedsterCore.Job {
    
    fileprivate func update(phases db: Database, jobId: Speedster.DbIdType) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        
        func addTo(futures phases: [Phase], stage: SpeedsterApi.Phase.Stage) {
            var x = preBuild.count
            for p in phases {
                let phase = SpeedsterApi.Phase.row(
                    from: p,
                    jobId: jobId,
                    order: x,
                    stage: stage
                )
                let future = phase.save(on: db)
                futures.append(future)
                x -= 1
            }
        }
        
        addTo(futures: preBuild, stage: .pre)
        addTo(futures: build, stage: .build)
        addTo(futures: postBuild, stage: .post)
        
        return futures.flatten(on: db.eventLoop)
    }
    
    public func guaranteedDbJobRowForAutomaticManagement(org: String, repo: String, on db: Database) -> EventLoopFuture<Row<Job>> {
        let githubRepo = "\(org)/\(repo)"
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
                    return job.save(on: db).flatMap { _ in
                        guard let jobId = job.id else {
                            return db.eventLoop.makeFailedFuture(DbError.unknownId)
                        }
                        return self.update(phases: db, jobId: jobId).map { phases in
                            return job
                        }
                    }
                }
                job.update(from: self)
                return job.update(on: db).flatMap { _ in
                    guard let jobId = job.id else {
                        return db.eventLoop.makeFailedFuture(DbError.unknownId)
                    }
                    return self.update(phases: db, jobId: jobId).map { phases in
                        return job
                    }
                }
        }
    }
    
}
