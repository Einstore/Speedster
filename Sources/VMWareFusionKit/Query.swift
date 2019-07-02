//
//  Query.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Foundation


public struct QueryableProperty<QueryableType> {
    
    /// Queryable element accessor
    public var element: QueryableType?
    
    let fusion: VMWareFusion
    
    init(_ obj: QueryableType? = nil, fusion: VMWareFusion) {
        element = obj
        self.fusion = fusion
    }
    
}

/// Queryable protocol
public protocol Queryable {
    
    /// Supported testable type
    associatedtype ObjectType

    /// Main static function to access github queries
    static func query(on fusion: VMWareFusion) -> QueryableProperty<ObjectType>
    
}


extension Queryable {
    
    /// Main static function to access github queries
    public static func query(on fusion: VMWareFusion) -> QueryableProperty<Self> {
        return QueryableProperty<Self>(fusion: fusion)
    }
    
}
