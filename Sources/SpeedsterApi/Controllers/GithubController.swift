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
    }
    
}
