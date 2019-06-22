//
//  ScheduledManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent


class ScheduledManager {
    
    typealias Tuple = (job: Row<Job>, scheduled: Row<Scheduled>)
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func scheduled(_ id: Speedster.DbIdType?) -> EventLoopFuture<Tuple> {
        return Scheduled.query(on: self.db)
            .filter(\Scheduled.id == id)
            .firstUnwrapped().flatMap { scheduled in
                return Job.query(on: self.db)
                    .filter(\Job.id == scheduled.jobId)
                    .firstUnwrapped().map { job in
                        return (job, scheduled)
                }
        }
    }
    
}
