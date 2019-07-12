//
//  CredentialsController.swift
//  
//
//  Created by Ondrej Rafaj on 12/07/2019.
//

import Fluent


class CredentialsController: Controller {
    
    let db: Database
    
    required init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("credentials") { req -> EventLoopFuture<Response> in
            return Credentials.select(on: self.db).all().map { arr in
                return arr.map { Credentials.Display($0) }.asResponse()
            }
        }
        
        r.post("credentials") { req -> EventLoopFuture<Response> in
            let post = try req.content.decode(Credentials.Post.self)
            let object = Credentials.row(from: post)
            return object.save(on: self.db).map { _ in
                return object.asDisplay().asResponse(.created)
            }
        }
        
        r.get("credentials", ":cred_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("cred_id", as: Speedster.DbIdType.self)
            return Credentials.find(failing: id, on: self.db).map { object in
                return object.asDisplay().asResponse()
            }
        }
        
        r.delete("credentials", ":cred_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("cred_id", as: Speedster.DbIdType.self)
            return Credentials.find(failing: id, on: self.db).flatMap { object in
                return object.delete(on: self.db).asDeletedResponse(on: c)
            }
        }
    }
    
}

