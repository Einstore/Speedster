//
//  SpeedsterDb.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Fluent
import SpeedsterCore
import GitHubKit
import Jobs
import RedisKit
import JobsRedisDriver


public class Speedster {
    
    public typealias DbIdType = UUID
    
    static let controllers: [Controller.Type] = [
        NodesController.self,
        GithubController.self,
        JobsController.self,
        ScheduledController.self
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
        
        // Jobs
        s.provider(JobsProvider())

        s.extend(JobsConfiguration.self) { configuration, container in
            configuration.refreshInterval = .seconds(1)
            
            let job = try ExecutorJob(container)
            configuration.add(job)
        }
        
        s.register(JobsDriver.self) { c in
            let source = RedisConnectionSource(
                config: RedisConfiguration(
                    hostname: "127.0.0.1",
                    port: 6380,
                    password: nil,
                    database: 0,
                    logger: nil
                ),
                eventLoop: c.eventLoop
            )
            let pool = ConnectionPool<RedisConnectionSource>(source: source)
            return JobsRedisDriver(client: pool)
        }
    }
    
    public static func configure(migrations: inout Migrations, dbIdentifier: DatabaseID) throws {
        migrations.add(Node.autoMigration(), to: dbIdentifier)
        migrations.add(Run.autoMigration(), to: dbIdentifier)
        migrations.add(Job.autoMigration(), to: dbIdentifier)
        migrations.add(GitHubJob.autoMigration(), to: dbIdentifier)
        migrations.add(Workflow.autoMigration(), to: dbIdentifier)
        migrations.add(Phase.autoMigration(), to: dbIdentifier)
        migrations.add(Organization.autoMigration(), to: dbIdentifier)
        migrations.add(Scheduled.autoMigration(), to: dbIdentifier)
        
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
