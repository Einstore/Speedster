//
//  JobsController.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


final class JobsController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("jobs") { req -> EventLoopFuture<[Row<Job>]> in
            return Job.query(on: self.db).all()
        }
    }
    
}
