//
//  Response+Builder.swift
//  
//
//  Created by Ondrej Rafaj on 15/06/2019.
//

import Vapor


public struct ResponseMakeProperty {
    
    public static func deleted(_ headers: HTTPHeaders = [:]) -> Response {
        return Response(
            status: .ok,
            headers: headers,
            body: Response.Body()
        )
    }
    
}


extension Response {
    
    public static var make: ResponseMakeProperty.Type {
        return ResponseMakeProperty.self
    }
    
    public func asSucceededFuture(on eventLoop: EventLoop) -> EventLoopFuture<Response> {
        return eventLoop.makeSucceededFuture(self)
    }
    
    public func asSucceededFuture(on req: Request) -> EventLoopFuture<Response> {
        return asSucceededFuture(on: req.eventLoop)
    }
    
}
