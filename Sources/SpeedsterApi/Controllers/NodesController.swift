//
//  NodesController.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor
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
            node.running = 0
            return node.save(on: self.db).map { node }
        }
        
//        r.put("nodes", UUID.parameter?) { req -> EventLoopFuture<Row<Node>> in
//            req.parameters.get("node")
//            let node = try req.content.decode(Row<Node>.self)
//            return node.update(on: self.db).map { node }
//        }
    }
    
}


