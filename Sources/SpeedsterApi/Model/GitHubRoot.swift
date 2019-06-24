//
//  GitHubRoot.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


/// Executable job, has phases and runs
public struct GitHubRoot: Model {
    
    public static let shared = GitHubRoot()
    public static let entity = "githubroots"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    public let rootId = Field<Speedster.DbIdType?>("root_id")
    
    public let organization = Field<String>("organization")
    
    public let repo = Field<String>("repo")
    
}
