//
//  Async+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import NIO


extension EventLoopFuture {
    
    func void() -> EventLoopFuture<Void> {
        return map { _ in Void() }
    }
    
}

extension Array where Element == EventLoopFuture<Void> {
    
    func flatten(on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return .andAllSucceed(self, on: eventLoop)
    }
    
}
