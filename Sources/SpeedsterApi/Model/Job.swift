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
    
    public static let shared = Job()
    public static let entity = "jobs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    public let name = Field<String>("name")
    
    /// Full URL of a Github repo (ex.1 https://github.com/Einstore/Speedster)
    public let githubRepo = Field<String>("github")
    
    /// Timeout for the whole job (seconds, default 3600)
    public let timeout = Field<Int>("timeout")
    
    /// Job will timeout after an interval if no update is received (seconds, default 1800)
    public let timeoutOnInactivity = Field<Int>("timeout_inactivity")

}
