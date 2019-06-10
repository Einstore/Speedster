//
//  Organization.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Fluent
import Vapor
import GithubAPI


/// Single run of a phase in a job
public struct Organization: Model {
    
    public static let shared = Organization()
    public static let entity = "organizations"
    
    public let id = Field<Speedster.DbIdType?>("id")
    public let githubId = Field<Int>("github_id")
    public let name = Field<String>("name")
    public let displayName = Field<String>("display")
    public let icon = Field<String?>("icon")
    public let company = Field<String?>("company")
    public let full = Field<GithubAPI.Organization>("full")
    
}
