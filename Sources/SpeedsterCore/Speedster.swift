//
//  SpeedsterDb.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Fluent
import GitHubKit
import Jobs
import Redis
import JobsRedisDriver
import SystemController


public class Speedster {
    
    public typealias DbIdType = UUID
    
    static let controllers: [Controller.Type] = [
        NodesController.self,
        GithubController.self,
        JobsController.self,
        ScheduledController.self,
        CredentialsController.self,
        SpeedsterController.self
    ]
    
    public static func configure(services s: inout Services) throws {
        guard let token = Environment.get("PERSONAL_ACCESS_TOKEN") else {
            fatalError("Missing personal access token")
        }
        s.register(Github.self) { container in
            let config = Github.Config(
                username: "orafaj",
                token: token,
                server: "https://github.ford.com/api/v3/"
            )
            return try Github(config, eventLoop: container.eventLoop)
        }
        
        // Redis
        s.provider(RedisProvider())
        
        // Jobs
        s.provider(JobsProvider())
        s.extend(JobsConfiguration.self) { configuration, container in
            configuration.refreshInterval = .seconds(1)
            
            let job = try ExecutorJob(container)
            configuration.add(job)
        }
        s.register(JobsDriver.self) { c in
            return try JobsRedisDriver(client: c.make())
        }
    }
    
    public static func configure(migrations: inout Migrations, dbIdentifier: DatabaseID) throws {
        migrations.add(Credentials.autoMigration(), to: dbIdentifier)
        migrations.add(Organization.autoMigration(), to: dbIdentifier)
        migrations.add(Node.autoMigration(), to: dbIdentifier)
        migrations.add(GitHubJob.autoMigration(), to: dbIdentifier)
        migrations.add(Scheduled.autoMigration(), to: dbIdentifier)
        migrations.add(Execution.autoMigration(), to: dbIdentifier)
        migrations.add(Run.autoMigration(), to: dbIdentifier)
        
        migrations.add(Setup(), to: dbIdentifier)
    }
    
    public static func configure(routes r: Routes, on c: Container, db: Database? = nil) throws {
        let db: Database = try db ?? c.make()
        
        try SystemController.Controller().routes(r, c)
        
        for controllerType in controllers {
            let controller = controllerType.init(db)
            try controller.routes(r, c)
        }
    }
    
}
