//
//  EventLoopFuture+Async.swift
//  
//
//  Created by Ondrej Rafaj on 11/06/2019.
//

import Vapor


extension EventLoopFuture {
    
    public func completeQuietly() {
        whenComplete { _ in }
    }
    
    public func void() -> EventLoopFuture<Void> {
        return map { _ in Void() }
    }
    
    public func asNoContent() -> EventLoopFuture<Response> {
        return map { _ in Response.make.noContent() }
    }
    
    public func convert<T>(to type: T.Type = T.self, _ callback: @escaping (Value) throws -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        let promise = eventLoop.makePromise(of: T.self)
        return always { (res) in
            switch res {
            case .success(let expectation):
                do {
                    let mapped = try callback(expectation)
                    mapped.cascade(to: promise)
                } catch {
                    promise.fail(error)
                }
            case .failure(let error):
                promise.fail(error)
            }
            }.flatMap { _ in
                return promise.futureResult
        }
    }
    
}
