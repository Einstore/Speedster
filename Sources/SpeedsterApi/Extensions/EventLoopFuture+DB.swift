//
//  EventLoopFuture+DB.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Fluent


public extension EventLoopFuture where Value: OptionalType {

    func unwrapOrNotFound() -> EventLoopFuture<Value.WrappedType> {
        return unwrap(or: HTTPError.notFound)
    }
    
}
