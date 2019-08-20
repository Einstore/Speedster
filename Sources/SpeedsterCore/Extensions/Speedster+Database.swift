import Foundation
import Vapor
import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver


extension Speedster {
    
    @discardableResult public static func setup(database s: inout Services) throws -> DatabaseID {
        let dbId: DatabaseID
        
        if Environment.get("DB") == "postgres" {
            dbId = .psql
            
            s.extend(Databases.self) { dbs, c in
                try dbs.postgres(config: c.make())
            }
            
            s.register(PostgresConfiguration.self) { c in
                let port = Int(Environment.get("DB_PORT") ?? "5432")
                let conf = PostgresConfiguration(
                    hostname: Environment.get("DB_HOST") ?? "localhost",
                    port: port ?? 5432,
                    username: Environment.get("DB_USER") ?? "speedster",
                    password: Environment.get("DB_HPASSWORD") ?? "aaaaaa",
                    database: Environment.get("DB_DATABASE") ?? "speedster",
                    tlsConfiguration: nil
                )
                return conf
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
