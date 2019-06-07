//
//  File.swift
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
    }
    
}


