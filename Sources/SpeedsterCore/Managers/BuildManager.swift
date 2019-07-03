//
//  BuildManager.swift
//  
//
//  Created by Ondrej Rafaj on 22/06/2019.
//

import Fluent
import GitHubKit
import Redis


class BuildManager {
    
    enum Error: Swift.Error {
        case noAvailableNode
        case cannotCreateMachine
    }
    
    private let db: Database
    private let github: Github
    private let container: Container
    private let scheduleManager: ScheduledManager
    
    private let redis: RedisClient
    
    private var scheduledId: Speedster.DbIdType?
    
    private var execution: Row<Execution>!
    private var runs: [String: Row<Run>] = [:]
    
    
    // MARK: Public interface
    
    init(
        github: Github,
        container: Container,
        scheduleManager: ScheduledManager,
        scheduledId: Speedster.DbIdType?,
        on database: Database
        ) throws {
        self.github = github
        self.container = container
        self.scheduleManager = scheduleManager
        self.scheduledId = scheduledId
        self.db = database
        
        redis = try container.make(RedisClient.self)
    }
    
    func build() -> EventLoopFuture<Void> {
        return self.root().flatMap { root in
            return self.node(root).flatMap { node in
                return logging().flatMap {
                    return self.build(node)
                }
            }
        }
    }
    
    // MARK: Private interface
    
    private func logging() -> EventLoopFuture<Void> {
//        Prepare:
//        private var execution: Row<Execution>!
//        private var runs: [String: Row<Run>] = [:]
        fatalError()
    }
    
    private func root() -> EventLoopFuture<Root> {
        return scheduleManager.scheduled(scheduledId).flatMap { scheduledJob in
            return GitHubJob.find(failing: scheduledJob.jobId, on: self.db).flatMap { githubJob in
                let location = GitLocation(
                    org: githubJob.org,
                    repo: githubJob.repo,
                    commit: scheduledJob.commit
                )
                
                let githubManager = GithubManager(
                    github: self.github,
                    container: self.container,
                    on: self.db
                )
                return githubManager.speedster(for: location).flatMap { root in
                    do {
                        try ChecksManager.check(jobDependencies: root) // Check dependencies are set correctly
                        try EnvironmentManager.check(environments: root) // Check environments are set correctly
                    } catch {
                        return self.container.eventLoop.makeFailedFuture(error)
                    }
                    return self.container.eventLoop.makeSucceededFuture(root)
                }
            }
        }
    }
    
    private func node(_ root: Root) -> EventLoopFuture<Row<Node>> {
        let nodesManager = NodesManager(db)
        // Get the next available node
        return nodesManager.next(root.nodeLabels).flatMap { node in
            guard let node = node else {
                return self.container.eventLoop.makeFailedFuture(Error.noAvailableNode)
            }
            return self.container.eventLoop.makeSucceededFuture(node)
        }
    }
    
    private func build(_ node: Row<Node>) -> EventLoopFuture<Void> {
        return self.close()
    }
                
//                let promise = self.container.eventLoop.makePromise(of: Void.self)
//                let ex = Executioner(
//                    root: root,
//                    node: node,
//                    on: self.container.eventLoop) { (output, identifier) in
//                        self.output += (output + "\n")
//                        print(output)
//                        self.redis.append((output + "\n"), to: self.key).completeQuietly()
//                }
//                ex.run(finished: {
//                    self.run.result = 0
//                    promise.succeed(Void())
//                }) { error in
//                    promise.fail(error)
//                }
//                return promise.futureResult
    
    // MARK: Closing
    
    private func waitForNewNode() {
        // If no node is available
    }
    
    private func close() -> EventLoopFuture<Void> {
        fatalError()
//        run.output = output
//        run.finished = Date()
//        run.result = result
//        return run.save(on: db).flatMap { _ in
//            return self.redis.delete([self.key]).flatMap { _ in
//                self.scheduledJob.runId = self.run.id
//                return self.scheduledJob.update(on: self.db).flatMap {
//                    self.node.running -= 1
//                    return self.node.update(on: self.db)
//                }
//            }
//        }
    }
    
}
