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
        let scheduleManager = ScheduledManager(self.db)
        
        r.post("jobs", ":job_id", "schedule") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            let post = try? req.content.decode(GitReference.self)
            let github = try c.make(Github.self)
            let githubManager = GithubManager(
                github: github,
                container: c,
                on: self.db
            )
            return GitHubJob.find(failing: id, on: self.db).flatMap { githubJob in
                    return githubManager.getCommitForSchedule(
                        org: githubJob.org,
                        repo: githubJob.repo,
                        ref: post
                        ).flatMap { commit in
                            return githubJob.schedule(commit.sha, on: self.db).encodeResponse(status: .created, for: req)
                    }
            }
        }
        
        r.get("jobs", "scheduled") { req -> EventLoopFuture<[Row<Scheduled>]> in
            return Scheduled.query(on: self.db)
//                .filter(\Scheduled.runId != nil)
                .sort(\Scheduled.requested, .ascending)
                .all()
        }
        
        r.get("scheduled", ":scheduled_id") { req -> EventLoopFuture<Row<Scheduled>> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return scheduleManager.scheduled(id)
        }
        
        let github = try c.make(Github.self)
        
        r.post("scheduled", ":scheduled_id", "run") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            let buildManager = try BuildManager(
                github: github,
                container: c,
                scheduleManager: scheduleManager,
                on: self.db
            )
            return try buildManager.build(id, trigger: Root.Pipeline.Trigger(branch: "master")).map { _ in
                return Response.make.noContent()
            }
        }
        
        r.post("scheduled", ":scheduled_id", "run", ":branch") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            guard let branch = req.parameters.get("branch", as: String.self) else {
                throw GenericError.missingParamater("branch Id")
            }
            let buildManager = try BuildManager(
                github: github,
                container: c,
                scheduleManager: scheduleManager,
                on: self.db
            )
            return try buildManager.build(id, trigger: Root.Pipeline.Trigger(branch: branch)).map { _ in
                return Response.make.noContent()
            }
        }
    }
    
}
