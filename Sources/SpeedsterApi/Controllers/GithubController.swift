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
        let github = try c.make(Github.self)
        let githubManager = GithubManager(
            github: github,
            container: c,
            on: self.db
        )
        
        r.get("github", "api", "organizations") { req -> EventLoopFuture<[GitHubKit.Organization]> in
            return try GitHubKit.Organization.query(on: github).get()
        }
        
        r.get("github", "api", "organizations", ":org", "repos") { req -> EventLoopFuture<[GitHubKit.Repo]> in
            guard let org = req.parameters.get("org", as: String.self) else {
                    return c.eventLoop.makeFailedFuture(HTTPError.missingParamaters)
            }
            return try GitHubKit.Repo.query(on: github).get(org: org)
        }
        
        r.get("github", "api", "organizations", ":org", ":repo", "branches") { req -> EventLoopFuture<[GitHubKit.Branch]> in
            guard
                let org = req.parameters.get("org", as: String.self),
                let repo = req.parameters.get("repo", as: String.self)
                else {
                    return c.eventLoop.makeFailedFuture(HTTPError.missingParamaters)
            }
            return try GitHubKit.Branch.query(on: github).get(org: org, repo: repo)
        }
        
        r.get("github", "api", "organizations", ":org", ":repo", "hooks") { req -> EventLoopFuture<[GitHubKit.Webhook]> in
            guard
                let org = req.parameters.get("org", as: String.self),
                let repo = req.parameters.get("repo", as: String.self)
                else {
                    return c.eventLoop.makeFailedFuture(HTTPError.missingParamaters)
            }
            return try GitHubKit.Webhook.query(on: github).get(org: org, repo: repo)
        }
        
        r.post("github", ":githubjob_id", "webhooks", "reset") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("githubjob_id", as: Speedster.DbIdType.self)
            return GitHubJob.query(on: self.db)
                .join(\Root.id, to: \GitHubJob.rootId)
                .filter(\Root.id == id)
                .firstUnwrapped().flatMap { job in
                    let infos = [
                        SpeedsterFileInfo(
                            job: job.rootId,
                            org: job.organization,
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
        
        r.post("github", "reload") { req -> EventLoopFuture<Response> in
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
    }
    
}
