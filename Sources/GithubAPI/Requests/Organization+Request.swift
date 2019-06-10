//
//  Organization+Request.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Vapor


extension Organization: Queryable { }

extension Array: Queryable where Element == Organization {
    public typealias ObjectType = [Organization]
}

extension QueryableProperty where QueryableType == Organization {
    
    public func get(organization name: String) throws -> EventLoopFuture<Organization?> {
        return try github.get(QueryableType.self, path: "orgs/\(name.lowercased())")
    }
    
}

extension QueryableProperty where QueryableType == Array<Organization> {
    
}
