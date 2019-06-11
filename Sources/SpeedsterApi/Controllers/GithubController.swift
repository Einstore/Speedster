//
//  GithubController.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Vapor
import Fluent
import GithubAPI

import AsyncKit


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
            return try GithubAPI.Organization.query(on: c).getAll().flatMap() { orgs in
                return orgs.repos(on: c).flatMap { repos in
                    return GithubManager.fileData(repos, on: c).map { files in
                        return files.map({ $0.asInfo() })
                    }
                }
            }
        }
    }
    
}



