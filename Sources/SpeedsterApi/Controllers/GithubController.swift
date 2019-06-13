//
//  GithubController.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Vapor
import Fluent
import GithubAPI


final class GithubController: Controller {
    
    enum GithubError: Error {
        case unknownOrg
    }
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {        
        r.get("github", "reload") { req -> EventLoopFuture<[SpeedsterFileInfo]> in
            let system = try System(
                db: self.db,
                container: c,
                github: c.make()
            )
            return try GithubAPI.Organization.query(on: c).getAll().flatMap() { githubOrgs in // Get available organizations from Github
                return GithubManager.update(organizations: githubOrgs, on: self.db).flatMap { dbOrgs in // Update organizations
                    return githubOrgs.repos(on: c).flatMap { repos in // Get repos
                        return GithubManager.fileData(repos, on: c).flatMap { files in // Grt Speedster.json from repos
                            return GithubManager.process(files: files, repos: repos, on: system).flatMap { infos in // Process all Speedster.json files
                                return GithubManager.updateOrgStats(dbOrgs, on: self.db).map { // Update all affected organizations with the latest repo stats
                                    return infos
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
