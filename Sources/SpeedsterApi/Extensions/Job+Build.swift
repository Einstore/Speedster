//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 13/06/2019.
//

import SpeedsterCore
import Fluent


extension Row where Model == SpeedsterApi.Job {
    
    func coreJob(on db: Database) -> EventLoopFuture<SpeedsterCore.Job> {
        return Workflow.query(on: db)
            .filter(\Workflow.jobId == self.id)
            .all().flatMap { workflows in
            return Phase.query(on: db)
                .filter(\Phase.jobId == self.id)
                .sort(\Phase.order, .descending)
                .all().flatMap { phases in
                let job = SpeedsterCore.Job(
                    name: self.name,
                    repoUrl: self.repoUrl,
                    // TODO: Map workflows properly!!!!
                    workflows: []
                )
                return db.eventLoop.makeSucceededFuture(job)
            }
        }
    }
}
