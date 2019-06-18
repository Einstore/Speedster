//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


public class Executioner {
    
    /// Connector
    private(set) var executor: Executor
    
    /// Job to be executed
    let job: Job
    
    let eventLoop: EventLoop
    
    var output: ExecutorOutput
    
    /// Initializer
    public init(job: Job, node: Node, on eventLoop: EventLoop, output: @escaping ExecutorOutput) {
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
            self.output(out, identifier)
        }
    }
    
    public  typealias FailedClosure = ((Error) -> ())
    
    private func run(workflow: Job.Workflow, failed: @escaping FailedClosure) throws {
        DispatchQueue.global(qos: .background).async {
            do {
                for phase in workflow.preBuild {
                    try self.executor.run(phase, identifier: self.job.identifier)
                }
                for phase in workflow.build {
                    try self.executor.run(phase, identifier: self.job.identifier)
                }
                for phase in workflow.postBuild {
                    try self.executor.run(phase, identifier: self.job.identifier)
                }
                for workflow in self.job.workflows.filter({ $0.dependsOn == workflow.name }) {
                    try self.run(workflow: workflow, failed: failed)
                }
            } catch {
                failed(error)
            }
        }
    }
    
    /// Execute job
    public func run(finished: @escaping (() -> ()), failed: @escaping FailedClosure) {
        do {
            for workflow in job.workflows.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
                do {
                    try run(workflow: workflow, failed: failed)
                    if let success = workflow.success {
                        try self.executor.run(success, identifier: self.job.identifier)
                    }
                    if let always = workflow.always {
                        try self.executor.run(always, identifier: self.job.identifier)
                    }
                } catch {
                    if let fail = workflow.fail {
                        try self.executor.run(fail, identifier: self.job.identifier)
                    }
                    throw error
                }
            }
            finished()
        } catch {
            failed(error)
        }
    }
    
}
