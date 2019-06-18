//
//  QueryBuilder+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Fluent


extension QueryBuilder {
    
    public func firstUnwrapped() -> EventLoopFuture<Row<Model>> {
        return first().unwrapOrNotFound()
    }
    
}
