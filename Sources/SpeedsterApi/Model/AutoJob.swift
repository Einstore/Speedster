//
//  AutoJob.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


/// Executable job, has phases and runs
public struct AutoJob: Model {
    
    /// GitHub info
    public struct GitHub: Codable {
        
        /// Full server URL
        public let server: String? = "https://github.com"
        
        /// API URL
        public let api: String? = "https://api.github.com"
        
        /// Personal access token
        public let accessToken: String
        
        /// Manage clone on job level
        public let clone: String?
        
        /// Repo
        public let repo: String
        
        /// Organization
        public let org: String
        
        /// Branches affected
        public let branches: [Branch]
        
        enum CodingKeys: String, CodingKey {
            case server
            case api
            case accessToken = "token"
            case clone
            case repo
            case org
            case branches
        }
        
    }
    
    public static let shared = AutoJob()
    public static let entity = "autojobs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job name
    public let name = Field<String>("name")
    
    /// GitHub info & settings
    public let gitHub = Field<GitHub?>("github")
    
    /// Disable job
    public let disabled = Field<Int>("disabled")
    
}

