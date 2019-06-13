//
//  Job.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import Vapor


/// Executable job, has phases and runs
public struct Job: Model {
    
    /// Management level
    public enum Managed: Int, Codable {
        
        // Not managed, job is setup manually
        case not = 0
        
        /// Fully managed through connected personal access token
        case github = 1
        
        /// Manually pointing to a Speedsted.json file
        case manual = 2
    }
    
    public static let shared = Job()
    public static let entity = "jobs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job name
    public let name = Field<String>("name")
    
    /// Full URL of a repo (ex.1 https://github.com/Einstore/Speedster)
    public let repoUrl = Field<String?>("repo_url")

    /// Disable job; if a Speedster.json is deleted from an automatically managed repo, Job will get disabled
    public let disabled = Field<Int>("disabled")
    
    /// Automatically managed should there be any content
    public let speedsterFile = Field<SpeedsterCore.Job?>("speedster_file")
    
    /// Github repository name for automatically managed jobs
    public let githubRepo = Field<String?>("github_repo")
    
    /// Github organization name for automatically managed jobs
    public let githubOrg = Field<String?>("github_org")
    
    /// Github server for automatically managed jobs
    public let githubServer = Field<String?>("github_server")
    
    /// Type of management
    public let managed = Field<Managed>("managed", dataType: .int)



}
