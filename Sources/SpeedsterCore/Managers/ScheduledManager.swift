//
//  ScheduledManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent


class ScheduledManager {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func scheduled(_ id: Speedster.DbIdType?) -> EventLoopFuture<Row<Scheduled>> {
        return Scheduled.query(on: self.db)
            .filter(\Scheduled.id == id)
            .firstUnwrapped()
    }
    
    func schedule(id: Speedster.DbIdType?, ref: GitReference?, trigger: Root.Pipeline.Trigger, githubManager: GithubManager) -> EventLoopFuture<Row<Scheduled>> {
        return GitHubJob.find(failing: id, on: self.db).flatMap { githubJob in
            return githubManager.getCommitForSchedule(
                org: githubJob.org,
                repo: githubJob.repo,
                ref: ref
            ).flatMap { commit in
                return githubJob.schedule(
                    commit,
                    trigger: trigger,
                    on: self.db
                )
            }
        }
    }
    
}
