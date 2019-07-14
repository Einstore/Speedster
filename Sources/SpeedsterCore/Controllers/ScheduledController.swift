//
//  ScheduledController.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent
import GitHubKit


final class ScheduledController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        let github = try c.make(Github.self)
        let scheduleManager = ScheduledManager(self.db)
        let githubManager = GithubManager(
            github: github,
            container: c,
            on: self.db
        )
        
        r.post("jobs", ":job_id", "schedule") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            let ref = try? req.content.decode(GitReference.self)
            return scheduleManager.schedule(
                id: id,
                ref: ref,
                trigger: Root.Pipeline.Trigger(ref: ref?.value ?? "master"),
                githubManager: githubManager
            ).encodeResponse(status: .created, for: req)
        }
        
        r.get("scheduled") { req -> EventLoopFuture<[Row<Scheduled>]> in
            return Scheduled.query(on: self.db)
//                .filter(\Scheduled.runId != nil)
                .sort(\Scheduled.requested, .ascending)
                .all()
        }
        
        r.get("scheduled", ":scheduled_id") { req -> EventLoopFuture<Row<Scheduled>> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return scheduleManager.scheduled(id)
        }
        
        r.delete("scheduled", ":scheduled_id") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return Scheduled.delete(failing: id, on: self.db).asDeletedResponse(on: c)
        }
        
        r.post("scheduled", ":scheduled_id", "run") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            let buildManager = try BuildManager(
                github: github,
                container: c,
                scheduleManager: scheduleManager,
                on: self.db
            )
            return try buildManager.build(id).map { _ in
                return Response.make.noContent()
            }
        }
    }
    
}
