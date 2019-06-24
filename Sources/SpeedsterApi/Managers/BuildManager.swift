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
    let github: Github
    let container: Container
    
    init(github: Github, container: Container, on database: Database) {
        self.github = github
        self.container = container
        self.db = database
    }
    
    func build(_ location: GitLocation) -> EventLoopFuture<Void> {
        let githubManager = GithubManager(
            github: github,
            container: container,
            on: db
        )
        return githubManager.speedster(for: location).flatMap { root in
            let promise = self.db.eventLoop.makePromise(of: Void.self)
            let ex = Executioner(
                root: root,
                node: SpeedsterCore.Node(
                    name: "Ubuntu Test",
                    host: "157.230.106.39",
                    port: 22,
                    user: "root",
                    password: "exploited",
                    publicKey: nil,
                    auth: .password
                ),
                on: self.db.eventLoop) { (output, identifier) in
                    print(output)
            }
            ex.run(finished: {
                promise.succeed(Void())
            }) { error in
                promise.fail(error)
            }
            return promise.futureResult
        }
    }
    
//    func build(_ tuple: ScheduledManager.Tuple) -> EventLoopFuture<Void> {
//        if let location = tuple.scheduled.github?.location {
//            return build(location)
//        } else {
//            return build(tuple.job)
//        }
//    }
    
}
