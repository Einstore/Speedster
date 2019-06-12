//
//  Job.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


public struct Job: Content {
    
    public struct Workflow: Content {
        
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
        
        /// Workflow name
        public let name: String
        
        /// Depends on workflow (name)
        public let dependsOn: String?
        
        /// Pre-build phases
        public let preBuild: [Phase]
        
        /// Build phases
        public let build: [Phase]
        
        /// Post-build phases
        public let postBuild: [Phase]
        
        /// Timeout for the whole job (seconds, default 3600)
        public let timeout: Int
        
        /// Job will timeout after an interval if no update is received (seconds, default 1800)
        public let timeoutOnInactivity: Int
        
        enum CodingKeys: String, CodingKey {
            case name
            case dependsOn = "depends"
            case timeout
            case timeoutOnInactivity = "timeout_inactivity"
            case preBuild = "pre_build"
            case build
            case postBuild = "post_build"
        }

        /// Initializer
        public init(name: String, dependsOn: String? = nil, timeout: Int, timeoutOnInactivity: Int, preBuild: [Phase], build: [Phase], postBuild: [Phase]) {
            self.name = name
            self.dependsOn = dependsOn
            self.timeout = timeout
            self.timeoutOnInactivity = timeoutOnInactivity
            self.preBuild = preBuild
            self.build = build
            self.postBuild = postBuild
        }

    }
    
    /// Job name
    public let name: String
    
    /// Full repo URL
    public let repoUrl: String?
    
    /// Workflows
    public let workflows: [Workflow]
    
    enum CodingKeys: String, CodingKey {
        case name
        case repoUrl = "repo_url"
        case workflows
    }
    
    /// Initializer
    public init(name: String, repoUrl: String? = nil, workflows: [Workflow]) {
        self.name = name
        self.repoUrl = repoUrl
        self.workflows = workflows
    }
    
}


extension Job {
    
    var identifier: String {
        return name
    }
    
}
