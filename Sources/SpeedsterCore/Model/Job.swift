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
            
            public let identifier: String?
            
            /// Name of the job
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
        
        /// Script to start workspace specific environment
        public let environmnetStart: String?
        
        /// Script to stop workspace specific environment
        public let environmnetFinish: String?
        
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
            case environmnetStart = "environmnet_start"
            case environmnetFinish = "environmnet_finish"
            case preBuild = "pre_build"
            case build
            case postBuild = "post_build"
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
            environmnetStart: String? = nil,
            environmnetFinish: String? = nil,
            preBuild: [Phase],
            build: [Phase],
            postBuild: [Phase],
            fail: Phase? = nil,
            success: Phase? = nil,
            always: Phase? = nil,
            dockerDependendencies: [Dependency]? = nil,
            timeout: Int,
            timeoutOnInactivity: Int
        ) {
            self.name = name
            self.nodeLabels = nodeLabels
            self.dependsOn = dependsOn
            self.environmnetStart = environmnetStart
            self.environmnetFinish = environmnetFinish
            self.preBuild = preBuild
            self.build = build
            self.postBuild = postBuild
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
            let organization: String
            let repo: String
            let commit: String
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
    
    public struct Branch: Codable {
        
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
        
        public let workflows: [Workflow]?
        
        public init(name: String, action: Action, workflows: [Workflow]? = nil) {
            self.name = name
            self.action = action
            self.workflows = workflows
        }
        
    }
    
    public struct Dependency: Codable {
        
        public let image: String
        
        public let networkName: String
        
        public let exposeOnPort: Int?
        
        public let cmd: String
        
        public let entrypoint: String
        
        public let variables: [String: String]
        
    }
    
    /// Job name
    public let name: String
    
    /// Node labels
    public let nodeLabels: String?
    
    /// GitHub info & settings
    public let gitHub: GitHub?
    
    /// Workflows
    public let workflows: [Workflow]
    
    /// Script to start environment
    public let environmnetStart: String?
    
    /// Script to stop environment
    public let environmnetFinish: String?
    
    /// Docker dependencies
    public let dockerDependendencies: [Dependency]?
    
    /// Branch management
    public let branches: [Branch]
    
    enum CodingKeys: String, CodingKey {
        case name
        case nodeLabels = "node_labels"
        case gitHub = "github"
        case workflows
        case environmnetStart = "environmnet_start"
        case environmnetFinish = "environmnet_finish"
        case dockerDependendencies = "docker_dependencies"
        case branches
    }
    
    /// Initializer
    public init(
        name: String,
        nodeLabels: String? = nil,
        gitHub: GitHub? = nil,
        workflows: [Workflow],
        environmnetStart: String? = nil,
        environmnetFinish: String? = nil,
        dockerDependendencies: [Dependency]? = nil,
        branches: [Branch]
        ) {
        self.name = name
        self.nodeLabels = nodeLabels
        self.gitHub = gitHub
        self.workflows = workflows
        self.branches = branches
        self.environmnetStart = environmnetStart
        self.environmnetFinish = environmnetFinish
        self.dockerDependendencies = dockerDependendencies
    }
    
}


extension Job {
    
    public var identifier: String {
        return name
    }
    
}
