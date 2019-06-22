//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 22/06/2019.
//

import Fluent
import SpeedsterCore
import GitHubKit


class BuildManager {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func build(job: Row<Job>) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func build(github: SpeedsterCore.Job.GitHub.Location) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func build(_ tuple: ScheduledManager.Tuple) -> EventLoopFuture<Void> {
        if let location = tuple.scheduled.github?.location {
            return build(github: location)
        } else {
            return build(job: tuple.job)
        }
    }
    
}
