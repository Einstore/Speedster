//
//  ScheduledController.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent
import SpeedsterCore
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
            return Scheduled.query(on: self.db).all()
        }
        
        r.get("scheduled", ":scheduled_id") { req -> EventLoopFuture<Row<Scheduled>> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return scheduleManager.scheduled(id)
        }
        
        r.post("scheduled", ":scheduled_id", "run") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            let github = try c.make(Github.self)
            return scheduleManager.scheduled(id).flatMap { scheduledJob in
                return GitHubJob.find(failing: scheduledJob.jobId, on: self.db).flatMap { githubJob in
                    let buildManager = BuildManager(github: github, container: c, on: self.db)
                    let loc = GitLocation(
                        org: githubJob.org,
                        repo: githubJob.repo,
                        commit: scheduledJob.commit
                    )
                    return buildManager.build(loc).flatMap { _ in
                        return Scheduled.delete(failing: id, on: self.db).map {
                            return Response.make.noContent()
                        }
                        }.flatMapError { error -> EventLoopFuture<Response> in
                            // TODO: Write error into a log etc!!!!!!!!!!
                            return Scheduled.delete(failing: id, on: self.db).map {
                                return Response.make.noContent()
                            }
                    }
                }
            }
        }
    }
}
