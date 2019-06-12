//
//  Job.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


public struct Job: Content {
    
    public struct Phase: Content {
        
        /// Name of the job
        public let name: String
        
        /// Command to be executed
        public let command: String
        
        /// Phase description, informative only
        public let description: String
        
        /// Initializer
        public init(name: String, command: String, description: String) {
            self.name = name
            self.command = command
            self.description = description
        }

    }
    
    /// Job name
    public let name: String
    
    /// Full repo URL
    public let repoUrl: String?
    
    /// Timeout for the whole job (seconds, default 3600)
    public let timeout: Int
    
    /// Job will timeout after an interval if no update is received (seconds, default 1800)
    public let timeoutOnInactivity: Int
    
    /// Pre-build phases
    public let preBuild: [Phase]
    
    /// Build phases
    public let build: [Phase]
    
    /// Post-build phases
    public let postBuild: [Phase]
    
    enum CodingKeys: String, CodingKey {
        case name
        case repoUrl = "repo_url"
        case timeout
        case timeoutOnInactivity = "timeout_inactivity"
        case preBuild = "pre_build"
        case build
        case postBuild = "post_build"
    }
    
    /// Initializers
    public init(name: String, repoUrl: String? = nil, timeout: Int, timeoutOnInactivity: Int, preBuild: [Phase], build: [Phase], postBuild: [Phase]) {
        self.name = name
        self.repoUrl = repoUrl
        self.timeout = timeout
        self.timeoutOnInactivity = timeoutOnInactivity
        self.preBuild = preBuild
        self.build = build
        self.postBuild = postBuild
    }
    
}
