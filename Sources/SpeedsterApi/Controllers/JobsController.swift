//
//  JobsController.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent
import SpeedsterCore
import Yams


final class JobsController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("jobs", ":job_id", "schedule") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            return Job.query(on: self.db)
                .filter(\Job.id == id)
                .firstUnwrapped().flatMap { job in
                    return job.scheduledResponse(on: self.db)
            }
        }
        
        r.get("jobs", "scheduled") { req -> EventLoopFuture<Response> in
            return Job.query(on: self.db)
                .join(\Scheduled.jobId, to: \Job.id)
                .sort(\Scheduled.requested, .ascending)
                .all().map { jobs in
                    return jobs.map { $0.asShort(managed: true) }
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
