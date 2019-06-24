//
//  RootController.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent
import SpeedsterCore
import Yams
import GitHubKit


final class RootController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("jobs", ":job_id") { req -> EventLoopFuture<Row<GitHubJob>> in
            let id = req.parameters.get("job_id", as: Speedster.DbIdType.self)
            return GitHubJob.query(on: self.db)
                .filter(\GitHubJob.id == id)
                .firstUnwrapped()
        }
        
        r.get("jobs") { req -> EventLoopFuture<[Row<GitHubJob>]> in
            return GitHubJob.query(on: self.db).all()
        }
        
        r.post("jobs", "validate") { req -> SpeedsterCore.Root in
            guard let yaml = req.body.string else {
                throw HTTPError.notFound
            }
            let job = try YAMLDecoder().decode(SpeedsterCore.Root.self, from: yaml)
            return job
        }
    }
    
}
