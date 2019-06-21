//
//  JobsController.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent
import SpeedsterCore
import Yams
import GitHubKit


final class JobsController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.post("jobs", ":job_id", "schedule") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
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
                                return job.scheduledResponse(nil, on: self.db)
                            }
                            return githubManager.getCommitForSchedule(
                                org: githubJob.organization,
                                repo: githubJob.repo,
                                branch: nil
                                ).flatMap { branch in
                                    let gh = SpeedsterCore.Job.GitHub(
                                        cloneGit: nil,
                                        location: SpeedsterCore.Job.GitHub.Location(
                                            organization: githubJob.organization,
                                            repo: githubJob.repo,
                                            commit: branch.commit.sha
                                        )
                                    )
                                    return job.scheduledResponse(gh, on: self.db)
                            }
                    }
            }
        }
        
        r.get("jobs", ":job_id") { req -> EventLoopFuture<Row<Job>> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            return Job.query(on: self.db)
                .filter(\Job.id == id)
                .firstUnwrapped()
        }
        
        r.post("jobs", "add") { req -> EventLoopFuture<Response> in
            let post = try req.content.decode(SpeedsterCore.Job.self, using: YAMLDecoder())
            return post.save(on: self.db).flatMap { job in
                let info = SpeedsterFileInfo(
                    job: job.id,
                    org: "",
                    repo: "",
                    speedster: true,
                    invalid: false,
                    disabled: false
                )
                return post.update(jobChildren: job, info: info, container: c, on: self.db).flatMap { _ in
                    return job.asShort().encodeResponse(status: .created, for: req)
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
        
        r.get("jobs") { req -> EventLoopFuture<Response> in
            return GitHubJob.query(on: self.db).all().flatMap { githubJobs in
                return Job.query(on: self.db)
                    .sort(\Job.name, .ascending)
                    .all().map { jobs in
                        return jobs.map { job in job.asShort(managed: githubJobs.contains(where: { git in
                            job.id == git.id
                        })) }
                }
            }
        }
        
        r.post("jobs", "validate") { req -> SpeedsterCore.Job in
            guard let yaml = req.body.string else {
                throw HTTPError.notFound
            }
            let job = try YAMLDecoder().decode(SpeedsterCore.Job.self, from: yaml)
            return job
        }
    }
    
}
