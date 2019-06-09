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
    
    required init(_ node: Node, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.node = node
    }
    
    func run(_ phase: Job.Phase) throws -> String {
        try FileManager.default.createDirectory(atPath: node.dir, withIntermediateDirectories: true, attributes: nil)
        
        var value = ""
        if !phase.name.isEmpty {
            value.append("\(phase.name)\n")
        }
        if !phase.description.isEmpty {
            value.append("\(phase.description)\n")
        }
        value.append("$ \(phase.command)\n")
        
        let output = SwiftShell.run(bash: phase.command)
        
        value.append(output.stdout)
        value.append("\n")
        
        if output.succeeded {
            value.append("-------------------------\n")
            return value
        } else {
            value.append(output.stderror)
            value.append("\n")
            value.append("-------------------------\n")
            throw Error.fail(output.stderror)
        }
    }
    
    func close() {
        
    }
    
}
