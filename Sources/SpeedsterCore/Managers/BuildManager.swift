//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 22/06/2019.
//

import Fluent
import GitHubKit
import Redis


class BuildManager {
    
    enum Error: Swift.Error {
        case missingRunId
        case noAvailableNode
        case cannotCreateMachine
    }
    
    private let db: Database
    private let github: Github
    private let container: Container
    private let scheduleManager: ScheduledManager
    
    private let redis: RedisClient
    
    private var scheduledId: Speedster.DbIdType?
    
    private var scheduledJob: Row<Scheduled>!
    private var run: Row<Run>!
    private var node: Row<Node>!
    
    private var output: String = ""
    private var result: Int = -1
    
    
    // MARK: Public interface
    
    init(
        github: Github,
        container: Container,
        scheduleManager: ScheduledManager,
        on database: Database
        ) throws {
        self.github = github
        self.container = container
        self.scheduleManager = scheduleManager
        self.db = database
        
        redis = try container.make(RedisClient.self)
    }
    
    func build(scheduled id: Speedster.DbIdType?) -> EventLoopFuture<Void> {
        scheduledId = id
        return Run.query(on: self.db).filter(\Run.scheduledId == id).firstUnwrapped().flatMap { run in
            guard run.started == nil else {
                let newRun = Run.row()
                newRun.jobId = run.jobId
                newRun.scheduledId = run.scheduledId
                return newRun.save(on: self.db).flatMap { _ in
                    return self.run(newRun)
                }
            }
            return self.run(run)
        }
    }
    
    // MARK: Private interface
    
    private var key: String {
        return run.id!.uuidString
    }
    
    private func run(_ run: Row<Run>) -> EventLoopFuture<Void> {
        self.run = run
        self.run.started = Date()
        return self.run.save(on: self.db).flatMap { _ in
            return self.buildData(self.scheduledId).flatMap { buildData in
                return self.build(buildData.location)
            }
        }.always { result in
            switch result {
            case .failure(let error):
                if let error = error as? Error, error == Error.noAvailableNode {
                    self.redis.delete([self.key]).flatMap { _ in
                        return self.run.delete(on: self.db)
                    }.completeQuietly()
                } else {
                    self.close().completeQuietly()
                }
            default:
                self.close().completeQuietly()
            }
        }
    }
    
    private func waitForNewNode() {
        
    }
    
    private func buildData(_ id: Speedster.DbIdType?) -> EventLoopFuture<(scheduled: Row<Scheduled>, job: Row<GitHubJob>, location: GitLocation)> {
        return scheduleManager.scheduled(id).flatMap { scheduledJob in
            self.scheduledJob = scheduledJob
            return GitHubJob.find(failing: scheduledJob.jobId, on: self.db).map { githubJob in
                let loc = GitLocation(
                    org: githubJob.org,
                    repo: githubJob.repo,
                    commit: scheduledJob.commit
                )
                return (scheduled: scheduledJob, job: githubJob, location: loc)
            }
        }
    }
    
    private func build(_ location: GitLocation) -> EventLoopFuture<Void> {
        let githubManager = GithubManager(
            github: github,
            container: container,
            on: db
        )
        let nodesManager = NodesManager(db)
        return githubManager.speedster(for: location).flatMap { root in
            return nodesManager.next(root.nodeLabels).flatMap { node in
                guard let node = node else {
                    return self.container.eventLoop.makeFailedFuture(Error.noAvailableNode)
                }
                self.node = node
                self.run.speedster = root
                self.run.nodeId = node.id
                return self.run.save(on: self.db).flatMap { _ in
                    guard let machine = try? self.node.asCore() else {
                        return self.container.eventLoop.makeFailedFuture(Error.cannotCreateMachine)
                    }
                    let promise = self.container.eventLoop.makePromise(of: Void.self)
                    let ex = Executioner(
                        root: root,
                        // TODO: Get the next executor through a queue!!!!!!!!!!!!!
                        machine: machine,
                        on: self.container.eventLoop) { (output, identifier) in
                            self.output += (output + "\n")
                            print(output)
                            self.redis.append((output + "\n"), to: self.key).completeQuietly()
                    }
                    ex.run(finished: {
                        self.run.result = 0
                        promise.succeed(Void())
                    }) { error in
                        promise.fail(error)
                    }
                    return promise.futureResult
                }
            }
        }
    }
    
    private func close() -> EventLoopFuture<Void> {
        run.output = output
        run.finished = Date()
        run.result = result
        return run.save(on: db).flatMap { _ in
            return self.redis.delete([self.key]).flatMap { _ in
                self.scheduledJob.runId = self.run.id
                return self.scheduledJob.update(on: self.db).flatMap {
                    self.node.running -= 1
                    return self.node.update(on: self.db)
                }
            }
        }
    }
    
}
