//
//  Organization.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Fluent
import Vapor
import GithubAPI


/// Informational object about automatically managed organizations
public struct Organization: Model {
    
    public static let shared = Organization()
    public static let entity = "organizations"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Github ID
    public let githubId = Field<Int>("github_id")
    
    /// Name
    public let name = Field<String>("name")
    
    /// Display name
    public let displayName = Field<String>("display")
    
    /// Avatar URL
    public let icon = Field<String?>("icon")
    
    /// Company name
    public let company = Field<String?>("company")
    
    /// Number of active (non-disabled) jobs
    public let activeJobs = Field<Int>("active")
    
    /// Number of total jobs registered
    public let totalJobs = Field<Int>("total")
    
    /// Number of total jobs registered
    public let disabled = Field<Int>("disabled")
    
    public let server = Field<String>("server")
    
    /// Full API info
    public let full = Field<GithubAPI.Organization>("full", dataType: .json)
    
}
