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
        organization.server = "http://some_enterprise_server.com"
        organization.disabled = 0
    }
    
}

extension Row where Model == Organization {
    
    /// Update Organization row with data from API
    func update(_ organization: GithubAPI.Organization) {
        organization.update(self)
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
    
    func exists(_ org: Row<SpeedsterApi.Organization>) -> Bool {
        return filter({ $0.login == org.name }).count > 0
    }
    
    func first(_ org: Row<SpeedsterApi.Organization>) -> GithubAPI.Organization? {
        return filter({ $0.login == org.name }).first
    }
    
    mutating func remove(_ org: Row<SpeedsterApi.Organization>) {
        removeAll(where: { $0.login == org.name })
    }
    
}


extension Organization {
    
    /// Return a guaranteed Organization row
    static func row(_ organization: GithubAPI.Organization, on db: Database) -> EventLoopFuture<Row<Organization>> {
        return Organization.query(on: db).filter(\.githubId == organization.id).first().map() { org in
            guard let org = org else {
                let row = Organization.row()
                row.activeJobs = 0
                row.totalJobs = 0
                
                organization.update(row)
                return row
            }
            organization.update(org)
            return org
        }
    }
    
    
    
}
