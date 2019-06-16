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
        r.get("nodes") { req -> EventLoopFuture<[Row<Node>]> in
            return Node.query(on: self.db).all()
        }
        
        r.post("nodes") { req -> EventLoopFuture<Row<Node>> in
            let node = try req.content.decode(Row<Node>.self)
            node.id = nil
            node.running = 0
//            if let password = node.password {
//                node.password = try? Secrets.encrypt(password)
//            }
//            if let publicKey = node.publicKey {
//                node.publicKey = try? Secrets.encrypt(publicKey)
//            }
            return node.save(on: self.db).map { node }
        }
        
        r.get("nodes", ":node_id") { req -> EventLoopFuture<Row<Node>> in
            let id = req.parameters.get("node_id", as: UUID.self)
            return Node.find(id, on: self.db).flatMapThrowing { node in
                guard let node = node else {
                    throw HTTPError.notFound
                }
                return node
            }
        }
        
        r.put("nodes", ":node_id") { req -> EventLoopFuture<Row<Node>> in
            let id = req.parameters.get("node_id", as: UUID.self)
            let nodeData = try req.content.decode(Row<Node>.self)
            return Node.find(id, on: self.db).flatMap { node in
                guard let node = node else {
                    return req.eventLoop.makeFailedFuture(HTTPError.notFound)
                }
                node.update(from: nodeData)
                return node.update(on: self.db).map { node }
            }
        }
        
//        r.get("nodes", ":node_id") { req -> EventLoopFuture<Response> in
//            let id = req.parameters.get("node_id", as: UUID.self)
//            return Node.find(id, on: self.db).flatMap { node in
//                guard let node = node else {
//                    return req.eventLoop.makeFailedFuture(HTTPError.notFound)
//                }
//                return node.delete(on: self.db).map {
//                    return Response.make.deleted()
//                }
//            }
//        }
    }
    
}


extension UUID: LosslessStringConvertible {
    
    public init?(_ description: String) {
        self.init(uuidString: description)
    }
    
}
