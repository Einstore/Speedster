//
//  Root.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Yams
import WebErrorKit


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
            public init(
                identifier: String? = nil,
                name: String? = nil,
                command: String,
                description: String? = nil
                ) {
                self.identifier = identifier
                self.name = name
                self.command = command
                self.description = description
            }
            
        }
        
        /// Workflow name
        public let name: String
        
        /// Node labels
        public let nodeLabels: [String]?
        
        /// Depends on workflow (name)
        public let dependsOn: String?
        
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
        
        /// Environment for the current job only
        public let environment: Env?
        
        /// Docker dependencies
        public let dockerDependendencies: [Dependency]?
        
        /// Timeout for the whole job (seconds, default 3600)
        public let timeout: Int?
        
        /// Job will timeout after an interval if no update is received (seconds, default 1800)
        public let timeoutOnInactivity: Int?
        
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
            nodeLabels: [String]? = nil,
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
    
    /// Git helpers
    public struct Git: Codable {
        
        /// Reference repo information
        public struct Reference: Codable {
            
            /// Path to the reference repo folder; Default is /tmp/speedster/
            public let path: String?
            
            /// Origin link, either in https or SSH (git@repo) format
            public let origin: String
            
            /// Domain: RSA SHA 256 verification key
            ///     - Note: These values are used for reference repo and are added to the Node's ~/.ssh/known_hosts.
            ///     - Note: The SHA is used to verify there was no interference with the connection, alas man-in-the-middle attack
            public let rsa: [String: String]?
            
            /// SSH private key from credentials, requires a name for a value stored in the system
            public let ssh: [String]?
            
            public let fetchSubmodules: Bool?
            
            enum CodingKeys: String, CodingKey {
                case path
                case origin
                case rsa
                case ssh
                case fetchSubmodules = "submodules"
            }
            
            /// Initializer
            public init(
                path: String? = nil,
                origin: String,
                rsa: [String: String]?,
                ssh: [String]? = nil,
                fetchSubmodules: Bool? = nil
                ) {
                self.path = path
                self.origin = origin
                self.rsa = rsa
                self.ssh = ssh
                self.fetchSubmodules = fetchSubmodules
            }
            
        }
        
        /// Reference repo
        public let referenceRepo: Reference?
        
        public let apiDownload: Bool?
        
        enum CodingKeys: String, CodingKey {
            case referenceRepo = "reference"
            case apiDownload = "download"
        }
        
        /// Initializer
        public init(referenceRepo: Reference? = nil, apiDownload: Bool?) {
            self.referenceRepo = referenceRepo
            self.apiDownload = apiDownload
        }
        
    }
    
    /// Docker dependency environments
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
    
    /// Environment requirements
    public struct Env: Codable {
        
        /// Connection details for environment
        public struct Connection: Codable {
            
            public enum Auth: String, Codable {
                case none = "na"
                case me = "me"
                case password = "ps"
                case privateKey = "pk"
            }
            
            public let host: String
            public let port: Int
            public let auth: Auth
            
        }
        
        /// Image for environment
        public enum Image: Codable, Equatable {
            
            public enum Error: String, WebError {
                case invalidEnvironmentImageType
            }
            
            /// Docker image (ex. einstore/einstore:latest)
            case docker(image: String)
            
            /// VMWare image (name of the image, has to be installed on a node selected)
            case vmware(name: String)
            
            public func serialize() -> String {
                switch self {
                case .docker(image: let image):
                    return "docker;\(image)"
                case .vmware(name: let name):
                    return "vmware;\(name)"
                }
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)
                switch true {
                case string.prefix(7) == "vmware;":
                    self = .vmware(name: String(string.dropFirst(7)))
                case string.prefix(7) == "docker;":
                    self = .docker(image: String(string.dropFirst(7)))
                default:
                    throw Error.invalidEnvironmentImageType
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(serialize())
            }
            
        }
        
        /// Image type
        public let image: Image
        
        /// Amount of memory (RAM) available
        public let memory: String?
        
        /// Amount of storage available
        public let storage: String?
        
        /// Mounted folders (node: vm)
        public let mounts: [String: String]?
        
        /// Environmental variables
        public let variables: [String: String]?
        
        /// Build script for the environment
        public let build: String?
        
        public init(
            image: Image,
            memory: String,
            storage: String,
            mounts: [String: String]? = nil,
            variables: [String: String]? = nil,
            build: String? = nil
            ) {
            self.image = image
            self.memory = memory
            self.storage = storage
            self.mounts = mounts
            self.variables = variables
            self.build = build
        }
        
    }
    
    public struct Pipeline: Codable {
        
        public struct Trigger: Codable {
            
            public enum Action: Codable {
                
                case commit
                
                case manual
                
                case message(String)
                
                enum CodingKeys: String, CodingKey {
                    case commit
                    case manual
                    case message
                }
                
                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let string = try container.decode(String.self)
                    switch true {
                    case string == "commit":
                        self = .commit
                    case string == "manual":
                        self = .manual
                    case string.prefix(8) == "message:":
                        self = .message(string.replacingOccurrences(of: "message:", with: ""))
                    default:
                        throw GenericError.decodingError("Error decoding Root.Pipeline.Trigger.Action: \(string)")
                    }
                }
                
                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(synthesize())
                }
                
                public func synthesize() -> String {
                    switch self {
                    case .commit:
                        return "commit"
                    case .manual:
                        return "manual"
                    case .message(let value):
                        return "message:\(value)"
                    }
                }
                
            }
            
            public let ref: String
            
            public let action: Action
            
            enum CodingKeys: String, CodingKey {
                case ref
                case action
            }
            
            public init(ref: String, action: Action = .manual) {
                self.ref = ref
                self.action = action
            }
            
        }
        
        /// Pipeline name
        public let name: String
        
        /// Triggers for jobs within this pipeline
        ///     - Any successful trigger will trigger given jobs
        public let triggers: [Trigger]
        
        /// Jobs allowed within the pipeline
        public let jobs: [String]
        
        /// Initializer
        public init(name: String, triggers: [Trigger], jobs: [String]) {
            self.name = name
            self.triggers = triggers
            self.jobs = jobs
        }
        
    }
    
    /// Job name
    public let name: String
    
    /// Job identifier
    public let identifier: String?
    
    /// Node labels
    public let nodeLabels: [String]?
    
    /// Source code info & settings
    public let source: Git?
    
    /// Workspace folder for the entire node
    public let workspace: String?
    
    /// Workflows
    public let jobs: [Job]
    
    /// Scripts to manage environment
    public let environment: Env?
    
    /// Docker dependencies
    public let dockerDependendencies: [Dependency]?
    
    /// Branch management
    public let pipelines: [Pipeline]?
    
    /// Variables parsed through every build script in a format #{VARIABLE}
    public let scriptVariables: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case identifier
        case nodeLabels = "node_labels"
        case source
        case workspace
        case jobs = "jobs"
        case environment = "environment"
        case dockerDependendencies = "docker_dependencies"
        case pipelines
        case scriptVariables = "script_vars"
    }
    
    /// Initializer
    public init(
        name: String,
        identifier: String? = nil,
        nodeLabels: [String]? = nil,
        source: Git? = nil,
        workspace: String? = nil,
        jobs: [Job],
        environment: Env? = nil,
        dockerDependendencies: [Dependency]? = nil,
        pipelines: [Pipeline]? = nil,
        scriptVariables: [String: String]? = nil
        ) {
        self.name = name
        self.identifier = identifier
        self.nodeLabels = nodeLabels
        self.source = source
        self.workspace = workspace
        self.jobs = jobs
        self.environment = environment
        self.dockerDependendencies = dockerDependendencies
        self.pipelines = pipelines
        self.scriptVariables = scriptVariables
    }
    
}


extension Root {
    
    public func fullPipeline() -> Pipeline {
        let jobNames = jobs.map({ $0.name })
        let pipeline = Pipeline(
            name: "All jobs",
            triggers: [
                Pipeline.Trigger(ref: "master", action: .manual)
            ],
            jobs: jobNames
        )
        return pipeline
    }
    
    public static func decode(from string: String) throws -> Root {
        do {
            let root = try YAMLDecoder().decode(Root.self, from: string)
            return root
        } catch let error as DecodingError {
            switch error {
            case .keyNotFound(let key, let ctx):
                print(key)
                print(ctx)
                if let err = ctx.underlyingError { throw err }
            case .dataCorrupted(let ctx):
                print(ctx)
                if let err = ctx.underlyingError { throw err }
            case .typeMismatch(let type, let ctx):
                print(type)
                print(ctx)
                if let err = ctx.underlyingError { throw err }
            case .valueNotFound(let type, let ctx):
                print(type)
                if let err = ctx.underlyingError { throw err }
            default:
                throw GenericError.decodingError(nil)
            }
        } catch {
            throw error
        }
        throw GenericError.decodingError(nil)
    }
    
}

