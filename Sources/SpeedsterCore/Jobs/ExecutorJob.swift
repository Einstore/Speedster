//
//  ExecutorJob.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Jobs
import Vapor
import GitHubKit
import Fluent


struct ExecutorJob: Jobs.Job {
    
    let container: Container
    let github: Github
//    let db: Database
    
    init(_ c: Container) throws {
        container = c
        github = try c.make(Github.self)
    }
    
    struct ExecutorData: JobData {
        
    }
    
    func dequeue(_ context: JobContext, _ data: ExecutorData) -> EventLoopFuture<Void> {
        print(data)
        return context.eventLoop.future()
    }
    
    func error(_ context: JobContext, _ error: Error, _ data: ExecutorData) -> EventLoopFuture<Void> {
        //If you don't want to handle errors you can simply return a future. You can also omit this function entirely.
        return context.eventLoop.future()
    }
    
}

