//
//  Model+SingleItemActions.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


extension Model {
    
    public static func find(failing id: Self.ID?, on database: Database) -> EventLoopFuture<Row<Self>> {
        guard let id = id else {
            return database.eventLoop.makeFailedFuture(HTTPError.notFound)
        }
        return Self.query(on: database).filter(\.id == id).first().flatMap { item in
            guard let item = item else {
                return database.eventLoop.makeFailedFuture(HTTPError.notFound)
            }
            return database.eventLoop.makeSucceededFuture(item)
        }
    }
    
    public static func delete(failing id: Self.ID?, on database: Database) -> EventLoopFuture<Void> {
        guard let id = id else {
            return database.eventLoop.makeFailedFuture(HTTPError.notFound)
        }
        return Self.query(on: database).filter(\.id == id).delete()
    }
    
}
