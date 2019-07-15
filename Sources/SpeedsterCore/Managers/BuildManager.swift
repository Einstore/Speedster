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
    
    private var scheduledId: Speedster.DbIdType!
    
    private var githubJob: Row<GitHubJob>!
    private var execution: Row<Execution>!
    private var runs: [String: RunWrapper] = [:]
    
    lazy var githubManager: GithubManager = {
        return GithubManager(
            github: self.github,
            container: self.container,
            on: self.db
        )
    }()
    
    
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
    
    func build(_ scheduledId: Speedster.DbIdType?) throws -> EventLoopFuture<Void> {
        guard let scheduledId = scheduledId else {
            throw Error.missingScheduledId
        }
        self.scheduledId = scheduledId
        return self.repoInfo().flatMap { repoInfo in
            return self.node(repoInfo.root).flatMap { node in
                return self.logging(node: node).flatMap { _ in
                    return self.build(
                        repoInfo.root,
                        trigger: repoInfo.trigger,
                        location: repoInfo.location,
                        on: node
                    )
                }.always { result in
                    self.finishLogging().completeQuietly()
                }
            }
        }
    }
    
    // MARK: Private interface
    
    private func identifier(for jobName: String?) -> String {
        let name = jobName ?? "environment"
        return "\(scheduledId.uuidString)-\(execution.id!.uuidString)-\(name)".lowercased().safeText
    }
    
    private func logging(node: Row<Node>) -> EventLoopFuture<Void> {
        execution = Execution.row()
        execution.scheduledId = scheduledId
        execution.githubjobId = githubJob.id
        execution.nodeId = node.id
        execution.started = Date()
        return execution.save(on: db)
    }
    
    private func repoInfo() -> EventLoopFuture<(root: Root, trigger: Root.Pipeline.Trigger, location: GitLocation)> {
        return scheduleManager.scheduled(scheduledId).flatMap { scheduledJob in
            return GitHubJob.find(failing: scheduledJob.jobId, on: self.db).flatMap { githubJob in
                self.githubJob = githubJob
                let location = GitLocation(
                    org: githubJob.org,
                    repo: githubJob.repo,
                    commit: scheduledJob.commit.sha
                )
                return self.githubManager.speedster(for: location).flatMap { root in
                    do {
                        try ChecksManager.check(jobDependencies: root) // Check dependencies are set correctly
                        try EnvironmentManager.check(environments: root) // Check environments are set correctly
                    } catch {
                        return self.container.eventLoop.makeFailedFuture(error)
                    }
                    return self.container.eventLoop.makeSucceededFuture((
                        root: root,
                        trigger: scheduledJob.trigger,
                        location: location
                    ))
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
    
    private func build(_ root: Root, trigger: Root.Pipeline.Trigger, location: GitLocation, on node: Row<Node>) -> EventLoopFuture<Void> {
        let ex = Executioner(
            root: root,
            trigger: trigger,
            location: location,
            node: node,
            identifier: execution.id,
            github: github,
            on: self.db
        ) { update in
            switch update {
            case .started(job: let job):
                print("Started: \(job.name)")
                let run = self.guaranteed(run: job)
                run.save(on: self.db).completeQuietly()
            case .output(text: let text, job: let job):
                print(text)
                self.redis.append((text + "\n"), to: self.identifier(for: job?.name)).completeQuietly()
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
        return ex.run()
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
            return futures.flatten(on: self.container.eventLoop).flatMap { _ in
                self.redis.delete(self.runs.map { self.identifier(for: $0.key) }).void()
            }
        }
    }
    
    private func finish() -> EventLoopFuture<Void> {
        return finishLogging()
    }
    
    
}
