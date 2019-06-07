//
//  SpeedsterController.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor
import Fluent


final class SpeedsterController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("demo") { req -> EventLoopFuture<Row<Node>> in
            let node = Node.row()
            node.name = "Me"
            node.host = "localhost"
            node.port = 0
            return node.save(on: self.db).map({ node })
        }
    }
    
}
