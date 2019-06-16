//
//  AutojobController.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


final class AutojobController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        /// 
        r.get("crypt") { req -> String in
            let text = try Secrets.encrypt("this is my message, lorem ipsum dolor sit amet!!!!")
            return try Secrets.decrypt(text) ?? "unknown"
        }
        
        r.get("autojobs") { req -> EventLoopFuture<[Row<AutoJob>]> in
            return AutoJob.query(on: self.db).all()
        }
    }
    
}
