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
        r.get("github", "reload") { req -> EventLoopFuture<GithubAPI.Organization> in
            return try GithubAPI.Organization.query(on: c).get(organization: "fordeu").map() { org in
                guard let org = org else {
                    fatalError()
                }
                return org
            }
        }
    }
    
}
