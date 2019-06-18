//
//  SystemController.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent
import SpeedsterCore


final class SystemController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.post("jobs", "validate") { req -> SpeedsterCore.Job in
            let job = try req.content.decode(SpeedsterCore.Job.self)
            return job
        }
    }
    
}
