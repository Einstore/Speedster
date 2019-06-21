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


public class Speedster {
    
    public typealias DbIdType = UUID
    
    static let controllers: [Controller.Type] = [
        NodesController.self,
        GithubController.self,
        JobsController.self
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
//        s.register(Redis.self) { c in
//            return Redis
//        }
        
        // Jobs
//        s.register(JobsProvider.self) { c in
//            return JobsProvider(refreshInterval: .seconds(1))
//        }
//
//        s.extend(JobsConfiguration.self) { configuration, container in
//            let job = try ExecutorJob(container)
//            configuration.add(job)
//        }
        
//        s.extend(CommandConfiguration.self) { configuration, c in
//            try configuration.use(c.make(JobsCommand.self), as: "jobs")
//        }
        
//        s.register(JobsProvider.self, { c in
//            return JobsProvider(refreshInterval: .seconds(1))
//        })
//
//        // Register the Jobs command
//        s.extend(CommandConfiguration.self) { configuration, c in
//            try configuration.use(c.make(JobsCommand.self), as: "jobs")
//        }
//
//        s.register(JobsCommand.self) { c in
//            return try .init(queueService: c.make(), jobContext: .init(eventLoop: c.eventLoop), config: c.make())
//        }
//
//        s.register(JobsConfiguration.self) { c in
//            var config = JobsConfiguration()
//
//            let job = try ExecutorJob(c)
//            config.add(job)
//
//            return config
//        }
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
