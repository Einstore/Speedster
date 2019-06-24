//
//  Root.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


public struct Root: Content {
    
    public struct Job: Content {
        
        public struct Phase: Content {
            
            public let identifier: String?
            
            /// Name of the phase
            public let name: String?
            
            /// Command to be executed
            public let command: String
            
            /// Phase description, informative only
            public let description: String?
            
            /// Initializer
            public init(identifier: String? = nil, name: String? = nil, command: String, description: String? = nil) {
                self.identifier = identifier
                self.name = name
                self.command = command
                self.description = description
            }
            
        }
        
        /// Workflow name
        public let name: String
        
        /// Node labels
        public let nodeLabels: String?
        
        /// Depends on workflow (name)
        public let dependsOn: String?
        
        /// Scripts to manage workspace specific environment
        public let environment: Env?
        
        /// Pre-build phases
        public let preBuild: [Phase]
        
        /// Build phases
        public let build: [Phase]
        
        /// Phase description, informative only
        public let fail: [Phase]?
        
        /// Phase description, informative only
        public let success: [Phase]?
        
        /// Phase description, informative only
        public let always: [Phase]?
        
        /// Docker dependencies
        public let dockerDependendencies: [Dependency]?
        
        /// Timeout for the whole job (seconds, default 3600)
        public let timeout: Int
        
        /// Job will timeout after an interval if no update is received (seconds, default 1800)
        public let timeoutOnInactivity: Int
        
        enum CodingKeys: String, CodingKey {
            case name
            case nodeLabels = "node_labels"
            case dependsOn = "depends"
            case environment = "environment"
            case preBuild = "pre_build"
            case build
            case fail
            case success
            case always
            case dockerDependendencies = "docker_dependencies"
            case timeout
            case timeoutOnInactivity = "timeout_inactivity"
        }

        /// Initializer
        public init(
            name: String,
            nodeLabels: String? = nil,
            dependsOn: String? = nil,
            environment: Env? = nil,
            preBuild: [Phase],
            build: [Phase],
            fail: [Phase]? = nil,
            success: [Phase]? = nil,
            always: [Phase]? = nil,
            dockerDependendencies: [Dependency]? = nil,
            timeout: Int,
            timeoutOnInactivity: Int
        ) {
            self.name = name
            self.nodeLabels = nodeLabels
            self.dependsOn = dependsOn
            self.environment = environment
            self.preBuild = preBuild
            self.build = build
            self.fail = fail
            self.success = success
            self.always = always
            self.dockerDependendencies = dockerDependendencies
            self.timeout = timeout
            self.timeoutOnInactivity = timeoutOnInactivity
        }

    }
    
    /// GitHub info
    public struct GitHub: Codable {
        
        public struct Location: Codable {
            
            public let organization: String
            public let repo: String
            public let commit: String?
            
            public init(organization: String, repo: String, commit: String? = nil) {
                self.organization = organization
                self.repo = repo
                self.commit = commit
            }
            
        }
        
        /// Manage clone on job level
        public let cloneGit: String?
        
        /// Repo
        public let location: Location?
        
        enum CodingKeys: String, CodingKey {
            case cloneGit = "clone"
            case location
        }
        
        public init(cloneGit: String? = nil, location: Location? = nil) {
            self.cloneGit = cloneGit
            self.location = location
        }
        
    }
    
    public struct Trigger: Codable {
        
        public enum Action: Codable {
            
            public enum Error: Swift.Error {
                case decoding(String)
            }
            
            case commit
            
            case message(String)
            
            enum CodingKeys: String, CodingKey {
                case commit
                case message
            }
            
            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                if let _ = try? values.decode(String.self, forKey: .commit) {
                    self = .commit
                    return
                }
                if let value = try? values.decode(String.self, forKey: .message) {
                    self = .message(value)
                    return
                }
                throw Error.decoding("Error decoding Action: \(dump(values))")
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case .commit:
                    try container.encode("commit", forKey: .commit)
                case .message(let value):
                    try container.encode(value, forKey: .message)
                }
            }
            
        }
        
        public let name: String
        
        public let action: Action
        
        public let jobs: [String]
        
        enum CodingKeys: String, CodingKey {
            case name = "branch"
            case action
            case jobs = "jobs"
        }
        
        public init(name: String, action: Action, jobs: [String]) {
            self.name = name
            self.action = action
            self.jobs = jobs
        }
        
    }
    
    public struct Dependency: Codable {
        
        public let image: String
        public let networkName: String
        public let exposeOnPort: Int?
        public let cmd: String?
        public let entrypoint: String?
        public let variables: [String: String]?
        
        public init(
            image: String,
            networkName: String,
            exposeOnPort: Int? = nil,
            cmd: String? = nil,
            entrypoint: String? = nil,
            variables: [String: String]? = nil
            ) {
            self.image = image
            self.networkName = networkName
            self.exposeOnPort = exposeOnPort
            self.cmd = cmd
            self.entrypoint = entrypoint
            self.variables = variables
        }
        
    }
    
    public struct Env: Codable {
        
        public let start: String
        public let finish: String
        public let variables: [String: String]?
        
        public init(
            start: String,
            finish: String,
            variables: [String: String]? = nil
            ) {
            self.start = start
            self.finish = finish
            self.variables = variables
        }
        
    }
    
    /// Job name
    public let name: String
    
    /// Job identifier
    public let identifier: String?
    
    /// Node labels
    public let nodeLabels: String?
    
    /// GitHub info & settings
    public let gitHub: GitHub?
    
    /// Workflows
    public let jobs: [Job]
    
    /// Scripts to manage environment
    public let environment: Env?
    
    /// Docker dependencies
    public let dockerDependendencies: [Dependency]?
    
    /// Branch management
    public let pipelines: [Trigger]
    
    enum CodingKeys: String, CodingKey {
        case name
        case identifier
        case nodeLabels = "node_labels"
        case gitHub = "github"
        case jobs = "jobs"
        case environment = "environment"
        case dockerDependendencies = "docker_dependencies"
        case pipelines
    }
    
    /// Initializer
    public init(
        name: String,
        identifier: String? = nil,
        nodeLabels: String? = nil,
        gitHub: GitHub? = nil,
        jobs: [Job],
        environment: Env? = nil,
        dockerDependendencies: [Dependency]? = nil,
        pipelines: [Trigger]
        ) {
        self.name = name
        self.identifier = identifier
        self.nodeLabels = nodeLabels
        self.gitHub = gitHub
        self.jobs = jobs
        self.environment = environment
        self.dockerDependendencies = dockerDependendencies
        self.pipelines = pipelines
    }
    
}


extension Root {
    
    public var workspaceName: String {
        return name + "-" + (identifier ?? "direct")
    }
    
}
