//
//  LocalConnector.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import SwiftShell


class LocalExecutor: Executor {
    
    enum Error: Swift.Error {
        case fail(String)
    }
    
    let node: Node
    
    let eventLoop: EventLoop
    
    let output: ExecutorOutput
    
    required init(_ node: Node, on eventLoop: EventLoop, output: @escaping ExecutorOutput) {
        self.eventLoop = eventLoop
        self.node = node
        self.output = output
    }
    
    func run(_ phase: Job.Phase) throws {
        try FileManager.default.createDirectory(atPath: node.dir, withIntermediateDirectories: true, attributes: nil)
        
        if !phase.name.isEmpty {
            output("\(phase.name)\n")
        }
        if !phase.description.isEmpty {
            output("\(phase.description)\n")
        }
        output("$ \(phase.command)\n")
        
        let context = CustomContext(main)
        let res = context.run(bash: phase.command)
        
        output(res.stdout)
        output("\n")
        
        if res.succeeded {
            output("-------------------------\n")
        } else {
            output(res.stderror)
            output("\n")
            output("-------------------------\n")
            throw Error.fail(res.stderror)
        }
    }
    
    func close() throws {
        
    }
    
}
