//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Fluent


public class Executioner {
    
    public enum Error: Swift.Error, Equatable {
        case missingJob
        case nonZeroExit
        case unableToStartEnvironment
    }
    
    /// Job to be executed
    let root: Root?
    
    let eventLoop: EventLoop
    
    var output: ExecutorOutput?
    
    var processed: [String] = []
    
    /// Initializer
    public init(root: Root? = nil, node: Row<Node>, on eventLoop: EventLoop, output: ExecutorOutput? = nil) {
        self.eventLoop = eventLoop
        self.root = root
        self.output = output
    }
    
    public  typealias FailedClosure = ((Swift.Error) -> ())
    
    private func run(job: Root.Job, executor: Executor, failed: @escaping FailedClosure) throws {
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
    }
    
    struct JobResult {
        let exitCode: Int
        let error: Swift.Error?
    }
    
    var results: [String: JobResult] = [:]
    
    /// Execute job
    public func run(finished: @escaping (() -> ()), failed: @escaping FailedClosure) {
//        guard let root = self.root else {
//            eventLoop.execute {
//                failed(Error.missingJob)
//            }
//            return
//        }
//        for job in root.jobs.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
//            // Launch virtual machine
//            let envManager = EnvironmentManager(on: self.eventLoop)
//            guard let env = job.environment ?? root.environment else {
//                fatalError("Missing environment, this should have been checked before the run has started")
//            }
//            envManager.launch(environment: env).whenComplete { result in
//                // Handle if environment doesn't start
//                let connection: Root.Env.Connection
//                switch result {
//                case .success(let conn):
//                    connection = conn
//                case .failure(let error):
//                    self.results[job.name] = JobResult(exitCode: -1, error: error)
//                    return
//                }
//                DispatchQueue.global(qos: .background).async {
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
//                }
//            }
//        }
    }
    
    public func run(bash: String, finished: @escaping (() -> ()), failed: @escaping FailedClosure) {
        fatalError()
//        DispatchQueue.global(qos: .background).async {
//            do {
//                let res = try executor.run(bash)
//                guard res == 0 else {
//                    self.eventLoop.execute {
//                        failed(Error.nonZeroExit)
//                    }
//                    return
//                }
//                self.eventLoop.execute {
//                    finished()
//                }
//                try executor.close()
//            } catch {
//                self.eventLoop.execute {
//                    failed(error)
//                }
//                try? executor.close()
//            }
//        }
    }
    
    deinit {
        // TODO: This neeeds to be called!!!!!!!!!!!!!!!
        print(":)")
    }
    
}
