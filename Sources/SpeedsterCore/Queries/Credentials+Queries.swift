//
//  Credentials+Queries.swift
//  
//
//  Created by Ondrej Rafaj on 12/07/2019.
//

import Fluent


extension Credentials {
    
    public static func select(on db: Database) -> QueryBuilder<Self> {
        return query(on: db)
            .sort(\Credentials.name, .ascending)
            .sort(\Credentials.login, .ascending)
    }
    
    public static func select(name: [String], on db: Database) -> QueryBuilder<Self> {
        return query(on: db)
            .filter(\Credentials.name, in: name)
    }
    
}
