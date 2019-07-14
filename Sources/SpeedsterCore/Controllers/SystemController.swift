//
//  SystemController.swift
//  
//
//  Created by Ondrej Rafaj on 14/07/2019.
//

import Fluent


class SystemController: Controller {
    
    let db: Database
    
    required init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.post("system", "rsa", "sha") { req -> EventLoopFuture<Response> in
            // TODO: Return an RSA SHA key for server
            // QUESTION: Do we want to do this? We could write a manual instead :D
            fatalError()
        }
    }
    
}
