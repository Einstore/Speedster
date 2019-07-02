//
//  RootController.swift
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
        let github = try c.make(Github.self)
        let githubManager = GithubManager(
            github: github,
            container: c,
            on: self.db
        )
        
        r.get("jobs", ":job_id") { req -> EventLoopFuture<Row<GitHubJob>> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            return GitHubJob.query(on: self.db)
                .filter(\GitHubJob.id == id)
                .firstUnwrapped()
        }
        
        r.get("jobs") { req -> EventLoopFuture<[Row<GitHubJob>]> in
            return GitHubJob.query(on: self.db).all()
        }
        
        r.post("jobs", "validate") { req -> SpeedsterCore.Root in
            guard let yaml = req.body.string else {
                throw HTTPError.notFound
            }
            let job = try YAMLDecoder().decode(SpeedsterCore.Root.self, from: yaml)
            return job
        }
        
        r.post("jobs", "reload") { req -> EventLoopFuture<Response> in
            return try GitHubKit.Organization.query(on: github).get().flatMap() { githubOrgs in // Get available organizations from Github
                return githubManager.update(organizations: githubOrgs).flatMap { dbOrgs in // Update organizations
                    return githubOrgs.repos(on: c).flatMap { repos in // Get repos
                        return githubManager.fileData(repos).flatMap { files in // Get Speedster.yml from repos
                            return githubManager.process(files: files, repos: repos).flatMap { infos in // Process all Speedster.yml files
                                return githubManager.update(orgStats: dbOrgs).flatMap { _ in // Update all affected organizations with the latest repo stats
                                    return githubManager.setup(webhooks: infos).map { // Setup webhooks
                                        return infos.asDisplayResponse()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        r.post("jobs", ":job_id", "webhooks", "reset") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            return GitHubJob.query(on: self.db)
                .filter(\GitHubJob.id == id)
                .firstUnwrapped().flatMap { job in
                    let infos = [
                        SpeedsterFileInfo(
                            job: job.id,
                            org: job.org,
                            repo: job.repo,
                            speedster: true,
                            invalid: false,
                            disabled: false
                        )
                    ]
                    return githubManager.reset(webhooks: infos).map { // Setup webhooks
                        return Response.make.noContent()
                    }
            }
        }
    }
    
}
