//
//  Job+Build.swift
//  
//
//  Created by Ondrej Rafaj on 13/06/2019.
//

import SpeedsterCore
import Fluent


extension Row where Model == SpeedsterApi.Root {
    
    func schedule(_ github: SpeedsterCore.Root.GitHub? = nil, on db: Database) -> EventLoopFuture<Row<Scheduled>> {
        let scheduled = Scheduled.row()
        scheduled.jobId = self.id
        scheduled.requested = Date()
        scheduled.github = github
        return scheduled.save(on: db).map { _ in
            return scheduled
        }
    }
    
    func scheduledResponse(_ github: SpeedsterCore.Root.GitHub? = nil, on db: Database) -> EventLoopFuture<Row<Scheduled>> {
        return schedule(github, on: db)
    }
    
    func coreJob(from jobs: [Row<Job>], phases: [Row<Phase>], on eventLoop: EventLoop) -> EventLoopFuture<SpeedsterCore.Root> {
        let job = SpeedsterCore.Root(
            name: self.name,
            nodeLabels: self.nodeLabels,
            gitHub: self.gitHub,
            jobs: jobs.assembleAsCore(phases),
            environment: self.environment,
            dockerDependendencies: self.dockerDependendencies,
            pipelines: []
        )
        return eventLoop.makeSucceededFuture(job)
    }
    
    func relatedData(on db: Database) -> EventLoopFuture<(jobs: [Row<Job>], phases: [Row<Phase>])> {
        return Job.query(on: db)
            .filter(\Job.rootId == self.id)
            .all().flatMap { jobs in
                return Phase.query(on: db)
                    .filter(\Phase.rootId == self.id)
                    .sort(\Phase.order, .descending)
                    .all().map { phases in
                        return (jobs: jobs, phases: phases)
                }
        }
    }
    
    func coreJob(on db: Database) -> EventLoopFuture<SpeedsterCore.Root> {
        return relatedData(on: db).flatMap { data in
            return self.coreJob(from: data.jobs, phases: data.phases, on: db.eventLoop)
        }
    }
    
}
