//
//  NodesController.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent


final class NodesController: Controller {
    
    enum Error: Swift.Error {
        case errorExitCode
    }
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("nodes") { req -> EventLoopFuture<Response> in
            return Node.query(on: self.db).all().map { rows in
                return rows.asDisplayResponse()
            }
        }
        
        r.post("nodes") { req -> EventLoopFuture<Response> in
            let post = try req.content.decode(Node.Post.self)
            let node = Node.row()
            node.running = 0
            node.update(from: post)
            return node.save(on: self.db).map { _ in
                return node.asDisplayResponse(.created)
            }
        }
        
        r.get("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(failing: id, on: self.db).map { node in
                return node.asDisplayResponse()
            }
        }
        
        r.post("nodes", ":node_id", "install-docker") { req -> EventLoopFuture<String> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(failing: id, on: self.db).flatMap { node in
                guard let coreNode = try? node.asCore() else {
                    return c.eventLoop.makeFailedFuture(GenericError.decodingError)
                }
                do {
                    var output = ""
                    let res = try coreNode.run(bash: "ls", on: c.eventLoop) { out in
                        output += out
                    }
                    if res == 0 {
                        return c.eventLoop.makeSucceededFuture(output)
                    } else {
                        return c.eventLoop.makeFailedFuture(Error.errorExitCode)
                    }
                } catch {
                    return c.eventLoop.makeFailedFuture(error)
                }
            }
        }
        
        r.put("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            let nodeData = try req.content.decode(Node.Post.self)
            return Node.find(failing: id, on: self.db).flatMap { node in
                node.update(from: nodeData)
                return node.update(on: self.db).map { node.asDisplayResponse() }
            }
        }
        
        r.delete("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(failing: id, on: self.db).flatMap { node in
                return node.delete(on: self.db).asDeletedResponse(on: c)
            }
        }
    }
    
}
