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
        let nodesManager = NodesManager(self.db)
        
        r.get("nodes") { req -> EventLoopFuture<Response> in
            return Node.query(on: self.db).all().map { rows in
                return rows.map { $0.asDisplay() }.asResponse()
            }
        }
        
        r.post("nodes") { req -> EventLoopFuture<Response> in
            let post = try req.content.decode(Node.Post.self)
            let node = Node.row()
            node.running = 0
            node.update(from: post)
            return node.save(on: self.db).map { _ in
                return node.asDisplay().asResponse(.created)
            }
        }
        
        r.get("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            return Node.find(failing: id, on: self.db).map { node in
                return node.asDisplay().asResponse()
            }
        }
        
        r.webSocket("nodes", ":node_id", "install-docker") { (req, webSocket) in
            nodesManager.install("ls", req: req, webSocket: webSocket)
        }
        
        r.post("nodes", ":node_id", "install-docker") { req -> EventLoopFuture<String> in
            nodesManager.install(Scripts.installDockerUbuntu, req: req)
        }
        
        r.put("nodes", ":node_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
            let nodeData = try req.content.decode(Node.Post.self)
            return Node.find(failing: id, on: self.db).flatMap { node in
                node.update(from: nodeData)
                return node.update(on: self.db).map { node.asDisplay().asResponse() }
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
