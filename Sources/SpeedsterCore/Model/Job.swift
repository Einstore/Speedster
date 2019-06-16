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
        
        /// Phase description, informative only
        public let fail: Phase?
        
        /// Phase description, informative only
        public let success: Phase?
        
        /// Phase description, informative only
        public let always: Phase?
        
        /// Timeout for the whole job (seconds, default 3600)
        public let timeout: Int
        
        /// Job will timeout after an interval if no update is received (seconds, default 1800)
        public let timeoutOnInactivity: Int
        
        enum CodingKeys: String, CodingKey {
            case name
            case dependsOn = "depends"
            case preBuild = "pre_build"
            case build
            case postBuild = "post_build"
            case fail
            case success
            case always
            case timeout
            case timeoutOnInactivity = "timeout_inactivity"
        }

        /// Initializer
        public init(name: String, dependsOn: String? = nil, preBuild: [Phase], build: [Phase], postBuild: [Phase], fail: Phase? = nil, success: Phase? = nil, always: Phase? = nil, timeout: Int, timeoutOnInactivity: Int) {
            self.name = name
            self.dependsOn = dependsOn
            self.preBuild = preBuild
            self.build = build
            self.postBuild = postBuild
            self.fail = fail
            self.success = success
            self.always = always
            self.timeout = timeout
            self.timeoutOnInactivity = timeoutOnInactivity
        }

    }
    
    /// GitHub info
    public struct GitHub: Codable {
        
        /// Manage clone on job level
        public let cloneGit: String?
        
        /// Full repo URL
        public let repoUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case cloneGit = "clone"
            case repoUrl = "repo_url"
        }
        
        public init(cloneGit: String?, repoUrl: String?) {
            self.cloneGit = cloneGit
            self.repoUrl = repoUrl
        }
        
    }
    
    /// Job name
    public let name: String
    
    /// GitHub info & settings
    public let gitHub: GitHub?
    
    /// Workflows
    public let workflows: [Workflow]
    
    enum CodingKeys: String, CodingKey {
        case name
        case gitHub = "github"
        case workflows
    }
    
    /// Initializer
    public init(name: String, gitHub: GitHub? = nil, workflows: [Workflow]) {
        self.name = name
        self.gitHub = gitHub
        self.workflows = workflows
    }
    
}


extension Job {
    
    var identifier: String {
        return name
    }
    
}
