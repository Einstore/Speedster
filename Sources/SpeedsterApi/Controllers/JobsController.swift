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
        r.get("jobs", ":job_id") { req -> EventLoopFuture<Row<Root>> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            return Root.query(on: self.db)
                .filter(\Root.id == id)
                .firstUnwrapped()
        }
        
        r.post("jobs", "add") { req -> EventLoopFuture<Response> in
            let post = try req.content.decode(SpeedsterCore.Root.self, using: YAMLDecoder())
            let github = try c.make(Github.self)
            return post.save(on: self.db).flatMap { job in
                let info = SpeedsterFileInfo(
                    job: job.id,
                    org: "",
                    repo: "",
                    speedster: true,
                    invalid: false,
                    disabled: false
                )
                return post.update(jobChildren: job, info: info, github: github, on: self.db).flatMap { _ in
                    return job.asShort().encodeResponse(status: .created, for: req)
                }
            }
        }
        
        r.get("jobs") { req -> EventLoopFuture<Response> in
            return GitHubJob.query(on: self.db).all().flatMap { githubJobs in
                return Root.query(on: self.db)
                    .sort(\Root.name, .ascending)
                    .all().map { jobs in
                        return jobs.map { job in job.asShort(managed: githubJobs.contains(where: { git in
                            job.id == git.id
                        })) }
                }
            }
        }
        
        r.post("jobs", "validate") { req -> SpeedsterCore.Root in
            guard let yaml = req.body.string else {
                throw HTTPError.notFound
            }
            let job = try YAMLDecoder().decode(SpeedsterCore.Root.self, from: yaml)
            return job
        }
    }
    
}
