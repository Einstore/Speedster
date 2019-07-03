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
        case missingScheduledId
        case noAvailableNode
    }
    
    struct RunWrapper {
        let run: Row<Run>
        var exit: Int = -1
    }
    
    private let db: Database
    private let github: Github
    private let container: Container
    private let scheduleManager: ScheduledManager
    
    private let redis: RedisClient
    
    private var scheduledId: Speedster.DbIdType
    
    private var githubJob: Row<GitHubJob>!
    private var execution: Row<Execution>!
    private var runs: [String: RunWrapper] = [:]
    
    
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
        self.db = database
        
        guard let scheduledId = scheduledId else {
            throw Error.missingScheduledId
        }
        self.scheduledId = scheduledId
        
        redis = try container.make(RedisClient.self)
    }
    
    func build() -> EventLoopFuture<Void> {
        return self.root().flatMap { root in
            return self.node(root).flatMap { node in
                return self.logging(node: node).flatMap { _ in
                    return self.build(root, on: node)
                }.always { result in
                    self.finishLogging().completeQuietly()
                }
            }
        }
    }
    
    // MARK: Private interface
    
    private func identifier(for jobName: String) -> String {
        return "\(scheduledId.uuidString)-\(execution.id!.uuidString)-\(jobName)".lowercased().safeText
    }
    
    private func logging(node: Row<Node>) -> EventLoopFuture<Void> {
        execution = Execution.row()
        execution.scheduledId = scheduledId
        execution.githubjobId = githubJob.id
        execution.nodeId = node.id
        execution.started = Date()
        return execution.save(on: db)
    }
    
    private func root() -> EventLoopFuture<Root> {
        return scheduleManager.scheduled(scheduledId).flatMap { scheduledJob in
            return GitHubJob.find(failing: scheduledJob.jobId, on: self.db).flatMap { githubJob in
                self.githubJob = githubJob
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
    
    /// Get the next available node
    private func node(_ root: Root) -> EventLoopFuture<Row<Node>> {
        let nodesManager = NodesManager(db)
        return nodesManager.next(root.nodeLabels).flatMap { node in
            guard let node = node else {
                return self.container.eventLoop.makeFailedFuture(Error.noAvailableNode)
            }
            return self.container.eventLoop.makeSucceededFuture(node)
        }
    }
    
    private func guaranteed(run job: Root.Job) -> Row<Run> {
        guard let wrapper = runs[job.name] else {
            let run = Run.row()
            run.scheduledId = scheduledId
            run.githubjobId = githubJob.id
            run.executionId = execution.id
            run.started = Date()
            run.jobName = job.name
            run.job = job
            runs[job.name] = RunWrapper(run: run)
            return run
        }
        return wrapper.run
    }
    
    private func build(_ root: Root, on node: Row<Node>) -> EventLoopFuture<Void> {
        let promise = self.container.eventLoop.makePromise(of: Void.self)
        let ex = Executioner(
            root: root,
            node: node,
            on: self.container.eventLoop
        ) { update in
            switch update {
            case .started(job: let job):
                print("Started: \(job.name)")
                let run = self.guaranteed(run: job)
                run.save(on: self.db).completeQuietly()
            case .output(text: let text, job: let job):
                print(text)
                self.redis.append((text + "\n"), to: self.identifier(for: job.name)).completeQuietly()
            case .environment(error: let error, job: let job):
                print(error)
                let env = job.environment?.image.serialize() ?? root.environment?.image.serialize() ?? "n/a"
                let msg = error.localizedDescription + "\n" + "Error launching environment (\(env))"
                self.redis.append((msg), to: self.identifier(for: job.name)).completeQuietly()
                self.guaranteed(run: job).result = -2
            case .error(let error, job: let job):
                print(error)
                let msg = "Job error: " + error.localizedDescription + "\n"
                self.redis.append((msg), to: self.identifier(for: job.name)).completeQuietly()
                self.guaranteed(run: job).result = -3
            case .finished(let exit, let job):
                self.guaranteed(run: job).result = exit
            }
        }
        ex.run(finished: {
            self.finish().completeQuietly()
            promise.succeed(Void())
        }) { error in
            self.finish().completeQuietly()
            promise.fail(error)
        }
        return promise.futureResult
    }
    
    private func finishLogging() -> EventLoopFuture<Void> {
        execution.finished = Date()
        return execution.save(on: db).flatMap {
            var futures: [EventLoopFuture<Void>] = []
            self.runs.forEach { wrapper in
                let identifier = self.identifier(for: wrapper.key)
                let future: EventLoopFuture<Void> = self.redis.get(identifier).flatMap { output in
                    wrapper.value.run.result = wrapper.value.exit
                    wrapper.value.run.output = output
                    wrapper.value.run.finished = Date()
                    return wrapper.value.run.save(on: self.db)
                }
                futures.append(future)
            }
            return futures.flatten(on: self.container.eventLoop)
        }
    }
    
    private func finish() -> EventLoopFuture<Void> {
        return finishLogging()
    }
    
    
}
