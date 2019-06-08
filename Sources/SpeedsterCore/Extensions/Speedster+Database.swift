//
//  Speedster+Database.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver


extension Speedster {
    
    @discardableResult public static func setup(database s: inout Services) throws -> DatabaseID {
        let dbId: DatabaseID
        
        if try Environment.detect().arguments.first! != "psql" {
            dbId = .psql
            
            s.extend(Databases.self) { dbs, c in
                try dbs.postgres(config: c.make())
            }
            
            s.register(PostgresConfiguration.self) { c in
                return .init(
                    hostname: "localhost",
                    port: 5432,
                    username: "speedster",
                    password: "aaaaaa",
                    database: "speedster",
                    tlsConfiguration: nil
                )
            }
            
            s.register(Database.self) { c in
                return try c.make(Databases.self).database(dbId)!
            }
        } else {
            dbId = .sqlite
            
            s.extend(Databases.self) { dbs, c in
                try dbs.sqlite(configuration: c.make(), threadPool: c.make())
            }
            
            s.register(SQLiteConfiguration.self) { c in
                return .init(storage: .connection(.file(path: "/tmp/speedster.sqlite")))
            }
            
            s.register(Database.self) { c in
                return try c.make(Databases.self).database(dbId)!
            }
        }
        return dbId
    }
    
}
