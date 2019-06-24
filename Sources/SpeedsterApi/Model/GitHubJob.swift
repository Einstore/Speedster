//
//  GitHubJob.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


/// Executable job
public struct GitHubJob: Model {
    
    public struct Short: Codable {
        
        public let id: Speedster.DbIdType?
        public let server: String?
        public let user: String?
        public let accessToken: String?
        public let org: String
        public let repo: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case server
            case user
            case accessToken = "access_token"
            case org
            case repo
        }
        
        init(
            id: Speedster.DbIdType? = nil,
            server: String? = nil,
            user: String? = nil,
            accessToken: String? = nil,
            org: String,
            repo: String
            ) {
            self.id = id
            self.server = server
            self.user = user
            self.accessToken = accessToken
            self.org = org
            self.repo = repo
        }
        
        init(_ row: Row<GitHubJob>) {
            self.id = row.id
            self.server = row.server
            self.user = row.user
            self.accessToken = row.accessToken
            self.org = row.org
            self.repo = row.repo
        }
        
    }
    
    public static let shared = GitHubJob()
    public static let entity = "github"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    public let server = Field<String?>("server")
    
    public let user = Field<String>("user")
    
    public let accessToken = Field<String>("token")
    
    public let org = Field<String>("org")
    
    public let disabled = Field<Int>("disabled")
    
    public let repo = Field<String>("repo")
    
}


extension Row where Model == GitHubJob {
    
    public func asShort() -> GitHubJob.Short {
        return GitHubJob.Short(self)
    }
    
}
