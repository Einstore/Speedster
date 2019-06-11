//
//  SpeedsterDb.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Fluent
import SpeedsterCore
import GithubAPI


public class Speedster {
    
    public typealias DbIdType = UUID
    
    static let controllers: [Controller.Type] = [
        NodesController.self,
        GithubController.self
    ]
    
    public static func configure(services s: inout Services) throws {
        s.register(Github.self) { container in
            let config = Github.Config(
                username: "orafaj",
                token: "6ae2ca8e8a9190be8fb6a864aaeaa3b0ecbf1b9a",
                server: "https://github.ford.com/api/v3/"
            )
            return try Github(config, on: container)
        }
    }
    
    public static func configure(migrations: inout Migrations, dbIdentifier: DatabaseID) throws {
        migrations.add(Node.autoMigration(), to: dbIdentifier)
        migrations.add(Run.autoMigration(), to: dbIdentifier)
        migrations.add(Job.autoMigration(), to: dbIdentifier)
        migrations.add(Phase.autoMigration(), to: dbIdentifier)
        migrations.add(Organization.autoMigration(), to: dbIdentifier)
        
        migrations.add(Setup(), to: dbIdentifier)
    }
    
    public static func configure(routes r: Routes, on c: Container, db: Database? = nil) throws {
        let db: Database = try db ?? c.make()
        
        for controllerType in controllers {
            let controller = controllerType.init(db)
            try controller.routes(r, c)
        }
    }
    
}
