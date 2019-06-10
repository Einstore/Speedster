//
//  File.swift
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
