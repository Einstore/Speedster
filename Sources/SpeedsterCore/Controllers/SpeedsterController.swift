//
//  SpeedsterController.swift
//  
//
//  Created by Ondrej Rafaj on 14/07/2019.
//

import Fluent
import SystemManager
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif


class SpeedsterController: Controller {
    
    let db: Database
    
    required init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        let logger = try c.make(Logger.self)
        logger.info("Routes for: \(#file)")
        logger.info("Version: 1")
        
        let nodesManager = NodesManager(db)
        
        r.post("system", "rsa", "sha") { req -> EventLoopFuture<Response> in
            // TODO: Return an RSA SHA key for server
            // QUESTION: Do we want to do this? We could write a manual instead :D
            fatalError()
        }
        
        r.get("nodes", ":node_id", "software") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(failing: id, on: self.db).flatMap { node in
                return nodesManager.software(for: node).map { soft in
                    return soft.asResponse()
                }
            }
        }
        
        r.get("nodes", ":node_id", "info") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(failing: id, on: self.db).flatMap { node in
                do {
                    let conn = try node.asShellConnection()
                    return try SystemManager(conn, on: c.eventLoop).info().map { info in
                        return info.asResponse()
                    }
                } catch {
                    return error.fail(c)
                }
            }
        }
        
        r.get("system", "flush") { req -> String in
            fflush(stdout)
            return ":)"
        }
    }
    
}
