//
//  GithubController.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Vapor
import Fluent
import GitHubKit


final class GithubController: Controller {
    
    enum GithubError: Error {
        case unknownOrg
    }
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("github", ":githubjob_id", "schedule") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("githubjob_id", as: Speedster.DbIdType.self)
            return Job.query(on: self.db)
                .join(\GitHubJob.jobId, to: \Job.id)
                .filter(\GitHubJob.id == id)
                .firstUnwrapped().flatMap { job in
                    return GitHubJob.query(on: self.db)
                        .filter(\GitHubJob.jobId == job.id)
                        .firstUnwrapped().flatMap { githubJob in
//                            return GitHubKit.Commit
                            return job.scheduledResponse(on: self.db)
                    }
            }
        }
        r.get("github", "reload") { req -> EventLoopFuture<Response> in
            let system = try System(
                db: self.db,
                container: c,
                github: c.make()
            )
            let github = try c.make(Github.self)
            return try GitHubKit.Organization.query(on: github).getAll().flatMap() { githubOrgs in // Get available organizations from Github
                return GithubManager.update(organizations: githubOrgs, on: self.db).flatMap { dbOrgs in // Update organizations
                    return githubOrgs.repos(on: c).flatMap { repos in // Get repos
                        return GithubManager.fileData(repos, on: c).flatMap { files in // Get Speedster.yml from repos
                            return GithubManager.process(files: files, repos: repos, on: system).flatMap { infos in // Process all Speedster.yml files
                                
                                return GithubManager.updateOrgStats(dbOrgs, on: self.db).map { // Update all affected organizations with the latest repo stats
                                    return infos.asDisplayResponse()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
