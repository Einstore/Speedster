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
            executor = LocalExecutor(node, on: eventLoop) { out in
                
            }
        } else {
            executor = RemoteExecutor(node, on: eventLoop) { out in
                
            }
        }
    }
    
    /// Execute job
    func run() throws -> String {
        for phase in job.preBuild {
            try executor.run(phase)
        }
        for phase in job.build {
            try executor.run(phase)
        }
        for phase in job.postBuild {
            try executor.run(phase)
        }
        return output
    }
    
}
