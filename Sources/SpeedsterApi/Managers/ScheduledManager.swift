//
//  ScheduledManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent


class ScheduledManager {
    
    typealias Tuple = (job: Row<Root>, scheduled: Row<Scheduled>)
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func scheduled(_ id: Speedster.DbIdType?) -> EventLoopFuture<Tuple> {
        return Scheduled.query(on: self.db)
            .filter(\Scheduled.id == id)
            .firstUnwrapped().flatMap { scheduled in
                return Root.query(on: self.db)
                    .filter(\Root.id == scheduled.jobId)
                    .firstUnwrapped().map { job in
                        return (job, scheduled)
                }
        }
    }
    
}
