//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation
import SpeedsterCore
import Fluent


extension Row where Model == Job {
    
    public func coreJob(on db: Database) -> EventLoopFuture<SpeedsterCore.Job> {
        let job = SpeedsterCore.Job(
            name: self.name,
            timeout: self.timeout,
            timeoutOnInactivity: self.timeoutOnInactivity,
            preBuild: [],
            build: [],
            postBuild: []
        )
        return db.eventLoop.makeSucceededFuture(job)
    }
    
}
