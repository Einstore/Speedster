//
//  Job+Build.swift
//  
//
//  Created by Ondrej Rafaj on 13/06/2019.
//

import SpeedsterCore
import Fluent


extension Row where Model == SpeedsterApi.Job {
    
    func schedule(on db: Database) -> EventLoopFuture<Void> {
        let scheduled = Scheduled.row()
        scheduled.jobId = self.id
        scheduled.requested = Date()
        return scheduled.save(on: db)
    }
    
    func scheduledResponse(on db: Database) -> EventLoopFuture<Response> {
        return schedule(on: db).map { _ in
            return Response.make.noContent()
        }
    }
    
    func coreJob(from workflows: [Row<Workflow>], phases: [Row<Phase>], on eventLoop: EventLoop) -> EventLoopFuture<SpeedsterCore.Job> {
        let job = SpeedsterCore.Job(
            name: self.name,
            nodeLabels: self.nodeLabels,
            gitHub: self.gitHub,
            workflows: workflows.assembleAsCore(phases),
            environmnetStart: self.environmnetStart,
            environmnetFinish: self.environmnetFinish,
            dockerDependendencies: self.dockerDependendencies,
            branches: []
        )
        return eventLoop.makeSucceededFuture(job)
    }
    
    func relatedData(on db: Database) -> EventLoopFuture<(workflows: [Row<Workflow>], phases: [Row<Phase>])> {
        return Workflow.query(on: db)
            .filter(\Workflow.jobId == self.id)
            .all().flatMap { workflows in
                return Phase.query(on: db)
                    .filter(\Phase.jobId == self.id)
                    .sort(\Phase.order, .descending)
                    .all().map { phases in
                        return (workflows: workflows, phases: phases)
                }
        }
    }
    
    func coreJob(on db: Database) -> EventLoopFuture<SpeedsterCore.Job> {
        return relatedData(on: db).flatMap { data in
            return self.coreJob(from: data.workflows, phases: data.phases, on: db.eventLoop)
        }
    }
    
}
