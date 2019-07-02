//
//  Job+Build.swift
//  
//
//  Created by Ondrej Rafaj on 13/06/2019.
//

import SpeedsterCore
import Fluent


extension Row where Model == GitHubJob {
    
    func schedule(_ commit: String, on db: Database) -> EventLoopFuture<Row<Scheduled>> {
        let scheduled = Scheduled.row()
        scheduled.jobId = self.id
        scheduled.runId = nil
        scheduled.commit = commit
        scheduled.requested = Date()
        return scheduled.save(on: db).flatMap { _ in
            let run = Run.row()
            run.scheduledId = scheduled.id
            run.jobId = self.id
            return run.save(on: db).map { _ in
                return scheduled
            }
        }
    }
    
}
