//
//  NodesController.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent


final class NodesController: Controller {
    
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
            return Node.find(id, on: self.db).flatMapThrowing { node in
                guard let node = node else {
                    throw HTTPError.notFound
                }
                return node.asDisplayResponse()
            }
        }
        
        r.put("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            let nodeData = try req.content.decode(Node.Post.self)
            return Node.find(id, on: self.db).flatMap { node in
                guard let node = node else {
                    return req.eventLoop.makeFailedFuture(HTTPError.notFound)
                }
                node.update(from: nodeData)
                return node.update(on: self.db).map { node.asDisplayResponse() }
            }
        }
        
        r.delete("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(id, on: self.db).flatMap { node in
                guard let node = node else {
                    return req.eventLoop.makeFailedFuture(HTTPError.notFound)
                }
                return node.delete(on: self.db).asDeletedResponse(on: c)
            }
        }
    }
    
}
