//
//  EventLoopFuture+Response.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent


extension EventLoopFuture where Value == Void {
    
    public func asDeletedResponse(on c: Container) -> EventLoopFuture<Response> {
        return c.eventLoop.makeSucceededFuture(
            Response.make.deleted()
        )
    }
    
}
