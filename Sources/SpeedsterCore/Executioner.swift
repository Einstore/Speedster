//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


public class Executioner {
    
    public enum Error: Swift.Error {
        case missingJob
    }
    
    /// Connector
    private(set) var executor: Executor
    
    /// Job to be executed
    let job: Job?
    
    let eventLoop: EventLoop
    
    var output: ExecutorOutput?
    
    var processed: [String] = []
    
    /// Initializer
    public init(job: Job? = nil, node: Node, on eventLoop: EventLoop, output: ExecutorOutput? = nil) {
        self.eventLoop = eventLoop
        self.job = job
        self.output = output
        
        if node.host == "localhost" {
            executor = LocalExecutor(node, on: eventLoop)
        } else {
            executor = RemoteExecutor(node, on: eventLoop)
        }
        
        executor.output = { out, identifier in
            let out = "[\(node.host)] \(out)"
            eventLoop.execute {
                self.output?(out, identifier)
            }
        }
    }
    
    public  typealias FailedClosure = ((Swift.Error) -> ())
    
    private func run(workflow: Job.Workflow, failed: @escaping FailedClosure) throws {
        guard let job = self.job else {
            throw Error.missingJob
        }
        //let address = Unmanaged.passUnretained().toOpaque()
        let identifier = try MD5.hash(.string("\(workflow)"))
        processed.append("\(identifier.string())")
        do {
            for phase in workflow.preBuild {
                try self.executor.run(phase, identifier: job.workspaceName)
            }
            for phase in workflow.build {
                try self.executor.run(phase, identifier: job.workspaceName)
            }
            for phase in workflow.success ?? [] {
                try self.executor.run(phase, identifier: job.workspaceName)
            }
            for phase in workflow.always ?? [] {
                try self.executor.run(phase, identifier: job.workspaceName)
            }
            for workflow in job.workflows.filter({ $0.dependsOn == workflow.name }) {
                let identifier = try MD5.hash(.string("\(workflow)"))
                if !processed.contains(identifier.string()) {
                    try self.run(workflow: workflow, failed: failed)
                }
            }
        } catch {
            do {
                for phase in workflow.fail ?? [] {
                    try self.executor.run(phase, identifier: job.workspaceName)
                }
            } catch {
                eventLoop.execute {
                    failed(error)
                }
                return
            }
            eventLoop.execute {
                failed(error)
            }
        }
    }
    
    /// Execute job
    public func run(finished: @escaping (() -> ()), failed: @escaping FailedClosure) {
        guard let job = self.job else {
            self.eventLoop.execute {
                failed(Error.missingJob)
            }
            return
        }
        DispatchQueue.global(qos: .background).async {
            do {
                for workflow in job.workflows.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
                    do {
                        try self.run(workflow: workflow, failed: failed)
                        if let success = workflow.success {
                            for p in success {
                                try self.executor.run(p, identifier: job.workspaceName)
                            }
                        }
                        if let always = workflow.always {
                            for p in always {
                                try self.executor.run(p, identifier: job.workspaceName)
                            }
                        }
                    } catch {
                        if let fail = workflow.fail {
                            for p in fail {
                                try self.executor.run(p, identifier: job.workspaceName)
                            }
                        }
                        throw error
                    }
                }
                self.eventLoop.execute {
                    finished()
                }
            } catch {
                self.eventLoop.execute {
                    failed(error)
                }
            }
        }
    }
    
    @discardableResult public func run(bash: String) throws -> Int {
        return try executor.run(bash)
    }
    
    deinit {
        // TODO: This neeeds to be called!!!!!!!!!!!!!!!
        print(":)")
    }
    
}
