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
            let post = try? req.content.decode(Scheduled.Ref.self)
            let github = try c.make(Github.self)
            let githubManager = GithubManager(
                github: github,
                container: c,
                on: self.db
            )
            return Job.query(on: self.db)
                .filter(\Job.id == id)
                .firstUnwrapped().flatMap { job in
                    return GitHubJob.query(on: self.db)
                        .filter(\GitHubJob.jobId == job.id)
                        .first().flatMap { githubJob in
                            guard let githubJob = githubJob else {
                                return job.scheduledResponse(nil, on: self.db).encodeResponse(status: .created, for: req)
                            }
                            
                            func schedule(for commit: Commit) -> EventLoopFuture<Row<Scheduled>> {
                                let gh = SpeedsterCore.Job.GitHub(
                                    cloneGit: nil,
                                    location: SpeedsterCore.Job.GitHub.Location(
                                        organization: githubJob.organization,
                                        repo: githubJob.repo,
                                        commit: commit.sha
                                    )
                                )
                                return job.scheduledResponse(gh, on: self.db)
                            }
                            
                            return githubManager.getCommitForSchedule(
                                org: githubJob.organization,
                                repo: githubJob.repo,
                                ref: post
                                ).flatMap { commit in
                                    return schedule(for: commit).encodeResponse(status: .created, for: req)
                            }
                    }
            }
        }
        
        r.get("jobs", "scheduled") { req -> EventLoopFuture<Response> in
            // TODO: Remove Scheduled query when .alsoDecode becomes available!!!!
            return Scheduled.query(on: self.db).all().flatMap { scheduled in
                return Job.query(on: self.db)
                    .join(\Scheduled.jobId, to: \Job.id)
                    .sort(\Scheduled.requested, .ascending)
                    .all().map { jobs in
                        return jobs.map { job in
                            Scheduled.Wrapper(
                                job: job.asShort(managed: true),
                                scheduled: scheduled.first(where: { $0.jobId == job.id })?.asShort()
                            )
                        }
                }
            }
        }
        
        r.get("scheduled", ":scheduled_id") { req -> EventLoopFuture<Scheduled.Wrapper> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return scheduleManager.scheduled(id).map { tuple in
                return Scheduled.Wrapper(
                    job: tuple.job.asShort(),
                    scheduled: tuple.scheduled.asShort()
                )
            }
        }
        
        r.post("scheduled", ":scheduled_id", "run") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            let github = try c.make(Github.self)
            return scheduleManager.scheduled(id).flatMap { tuple in
                let buildManager = BuildManager(github: github, container: c, on: self.db)
                return buildManager.build(tuple).flatMap { _ in
                    return Scheduled.delete(failing: id, on: self.db).map {
                        return Response.make.noContent()
                    }
                }
            }
        }
    }
}
