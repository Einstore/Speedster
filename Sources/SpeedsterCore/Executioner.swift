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
    
    var output: ((String) -> ())
    
    /// Initializer
    public init(job: Job, node: Node, on eventLoop: EventLoop, output: @escaping ((String) -> ())) {
        self.eventLoop = eventLoop
        self.job = job
        self.output = output
        
        if node.host == "localhost" {
            executor = LocalExecutor(node, on: eventLoop)
        } else {
            executor = RemoteExecutor(node, on: eventLoop)
        }
        
        executor.output = { out in
            let out = "[\(node.host)] \(out)"
            self.output(out)
        }
    }
    
    /// Execute job
    public func run(finished: @escaping (() -> ()), failed: @escaping ((Error) -> ())) {
        DispatchQueue.global(qos: .background).async {
            do {
                for phase in self.job.preBuild {
                    try self.executor.run(phase)
                }
                for phase in self.job.build {
                    try self.executor.run(phase)
                }
                for phase in self.job.postBuild {
                    try self.executor.run(phase)
                }
                finished()
            } catch {
                failed(error)
            }
        }
    }
    
}
