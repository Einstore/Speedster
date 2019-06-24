//
//  ScheduledManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent


class ScheduledManager {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func scheduled(_ id: Speedster.DbIdType?) -> EventLoopFuture<Row<Scheduled>> {
        return Scheduled.query(on: self.db)
            .filter(\Scheduled.id == id)
            .firstUnwrapped()
    }
    
}
