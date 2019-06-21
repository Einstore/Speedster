//
//  NodesManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent


class NodesManager {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func next(_ labels: [String]? = nil) -> EventLoopFuture<Row<Node>?> {
        let q = Node.query(on: db)
            .filter(\Node.running == 0)
        if let labels = labels {
            q.filter(\Node.labels, in: labels)
        }
        return q.first().flatMap { node in
            guard let node = node else {
                return self.db.eventLoop.makeSucceededFuture(nil)
            }
            node.running += 1
            return node.update(on: self.db).map { _ in
                return node
            }
        }
    }
    
}
