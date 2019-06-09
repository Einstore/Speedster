//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


class Executioner {
    
    private(set) var output = ""
    
    /// Connector
    let executor: Executor
    
    /// Job to be executed
    let job: Job
    
    let eventLoop: EventLoop
    
    /// Initializer
    init(job: Job, node: Node, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.job = job
        
        if node.host == "localhost" {
            executor = LocalExecutor(node, on: eventLoop)
        } else {
            executor = RemoteExecutor(node, on: eventLoop)
        }
    }
    
    /// Execute job
    func run() throws -> String {
        for phase in job.preBuild {
            let s = try executor.run(phase)
            output.append(s)
        }
        for phase in job.build {
            let s = try executor.run(phase)
            output.append(s)
        }
        for phase in job.postBuild {
            let s = try executor.run(phase)
            output.append(s)
        }
        return output
    }
    
}
