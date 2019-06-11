//
//  Organization+Speedster.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import GithubAPI
import Fluent


extension GithubAPI.Organization {
    
    /// Update Organization row with data from API
    func update(_ organization: Row<Organization>) {
        organization.name = login
        organization.githubId = id
        organization.displayName = name ?? login
        organization.company = company
        organization.icon = avatarURL
        organization.full = self
    }
    
}


extension Array where Element == GithubAPI.Organization {
    
    func repos(on c: Container) -> EventLoopFuture<[Repo]> {
        var futures: [EventLoopFuture<[Repo]>] = []
        for org in self {
            do {
                let future = try Repo.query(on: c).get(organization: org.login)
                futures.append(future)
            } catch {
                return c.eventLoop.makeFailedFuture(error)
            }
        }
        return futures.flatten(on: c.eventLoop).map { reposArr in
            let repos = reposArr.reduce([], +)
            return repos
        }
    }
    
}


extension Organization {
    
    /// Return a guaranteed Organization row
    static func row(_ organization: GithubAPI.Organization, on database: Database) -> EventLoopFuture<Row<Organization>> {
        return Organization.query(on: database).filter(\.githubId == organization.id).first().map() { org in
            guard let org = org else {
                let row = Organization.row()
                organization.update(row)
                return row
            }
            organization.update(org)
            return org
        }
    }
    
    
    
}
