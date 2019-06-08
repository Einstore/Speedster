//
//  Setup.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Fluent


struct Setup: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let node = Node.masterNode()
        return node.save(on: database)
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(Void())
    }
    
}
