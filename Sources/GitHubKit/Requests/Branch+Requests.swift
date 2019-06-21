//
//  Branch+Requests.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import NIO


extension Branch: Queryable { }


extension QueryableProperty where QueryableType == Branch {
    
    /// Get specific branch
    public func get(org: String, repo: String, branch name: String) throws -> EventLoopFuture<Branch> {
        return try github.get(path: "repos/\(org.lowercased())/\(repo.lowercased())/branches/\(name.lowercased())")
    }
    
    /// Get all available branches
    public func get(org: String, repo: String) throws -> EventLoopFuture<[Branch]> {
        return try github.get(path: "repos/\(org.lowercased())/\(repo.lowercased())/branches")
    }
    
}

