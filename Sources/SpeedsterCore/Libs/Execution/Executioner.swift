//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Fluent
import RefRepoKit
import ShellKit


class Executioner {
    
    enum UpdateData {
        case started(job: Root.Job)
        case output(text: String, job: Root.Job? = nil)
        case finished(exit: Int, job: Root.Job)
        case environment(error: Error, job: Root.Job)
        case error(_ error: Error, job: Root.Job)
    }
    
    typealias Update = ((UpdateData) -> ())
    
    /// Job to be executed
    let root: Root
    let node: Row<Node>
    
    // Pripeline
    let trigger: Root.Pipeline.Trigger
    let eventLoop: EventLoop
    
    var update: Update
    
    var processed: [String] = []
    
    var randomId: String
    
    // MARK: Public interface
    
    /// Initializer
    init(
        root: Root,
        trigger: Root.Pipeline.Trigger,
        node: Row<Node>,
        on eventLoop: EventLoop,
        update: @escaping Update
        ) {
        self.root = root
        self.trigger = trigger
        self.update = update
        self.eventLoop = eventLoop
        self.node = node
        randomId = "\(root.name.safeText)-\(UUID().uuidString)".lowercased()
    }
    
     typealias FailedClosure = ((Swift.Error) -> ())
    
    /// Execute job
    func run() -> EventLoopFuture<Void> {
        guard let referenceRepo = root.gitHub?.referenceRepo else {
            return runJobs()
        }
        do {
            let nodeConnection = try node.asShellConnection()
            let ref = try RefRepo(
                nodeConnection,
                temp: referenceRepo.path ?? "/tmp/speeedster/",
                on: eventLoop) { text in
                    self.make(update: .output(text: text))
            }
            return ref.clone(
                repo: referenceRepo.origin,
                checkout: trigger.branch,
                for: randomId
            ).flatMap { path in
                return self.runJobs(repoPath: path)
            }
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    // MARK: Private interface
    
    private func runJobs(repoPath: String? = nil) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for job in root.jobs.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
            // Launch virtual machine
            guard let env = job.environment ?? root.environment else {
                fatalError("Missing environment, this should have been checked before the run has started (favourite last words ... THIS SHOULD NEVER HAPPEN!)")
            }
            let envManager = EnvironmentManager(env, node: self.node, on: self.eventLoop)
            envManager.launch().whenComplete { result in
                let connection: Root.Env.Connection
                switch result {
                case .success(let conn):
                    connection = conn
                case .failure(let error):
                    self.make(update: .environment(error: error, job: job))
                    return
                }
                print(connection)
                
                DispatchQueue.global(qos: .background).async {
                    
                    fatalError()
                    
                    
//                    var executor = RemoteExecutor(connection, on: eventLoop)
//
//                    executor.output = { out, identifier in
//                        let out = "[\(connection.host)] \(out)"
//                        eventLoop.execute {
//                            self.output?(out, identifier)
//                        }
//                    }
//                    do {
//                        try self.run(job: job, failed: failed)
//                        if let success = job.success {
//                            for p in success {
//                                try executor.run(p, identifier: root.workspaceName)
//                            }
//                        }
//                        if let always = job.always {
//                            for p in always {
//                                try executor.run(p, identifier: root.workspaceName)
//                            }
//                        }
//                    } catch {
//                        if let fail = job.fail {
//                            for p in fail {
//                                try? executor.run(p, identifier: root.workspaceName)
//                            }
//                        }
//                        //throw error
//                    }
                }
            }
        }
        return futures.flatten(on: eventLoop)
    }
    
    private func make(update data: UpdateData) {
        eventLoop.execute {
            self.update(data)
        }
    }
    
//    private func run(job: Root.Job, failed: @escaping FailedClosure) throws {
//        guard let root = self.root else {
//            throw Error.missingJob
//        }
//        let identifier = try MD5.hash(.string("\(job)"))
//        processed.append("\(identifier.string())")
//        do {
//            for phase in job.preBuild {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for phase in job.build {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for phase in job.success ?? [] {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for phase in job.always ?? [] {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for workflow in root.jobs.filter({ $0.dependsOn == job.name }) {
//                let identifier = try MD5.hash(.string("\(workflow)"))
//                if !processed.contains(identifier.string()) {
//                    try self.run(job: workflow, failed: failed)
//                }
//            }
//        } catch {
//            do {
//                for phase in job.fail ?? [] {
//                    try executor.run(phase, identifier: root.workspaceName)
//                }
//            } catch {
//                eventLoop.execute {
//                    failed(error)
//                }
//                return
//            }
//            eventLoop.execute {
//                failed(error)
//            }
//        }
//    }
    
    deinit {
        // TODO: This neeeds to be called!!!!!!!!!!!!!!!
        print(":)")
    }
    
}
