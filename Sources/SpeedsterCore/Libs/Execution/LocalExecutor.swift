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
    
    var output: ExecutorOutput?
    
    required init(_ node: Node, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.node = node
    }
    
    func run(_ phase: Job.Phase) throws {
        try FileManager.default.createDirectory(atPath: node.dir, withIntermediateDirectories: true, attributes: nil)
        
        if !phase.name.isEmpty {
            output?("\(phase.name)")
        }
        if !phase.description.isEmpty {
            output?("\(phase.description)")
        }
        output?("$ \(phase.command)")
        
        let context = CustomContext(main)
        let res = context.run(bash: phase.command)
        
        output?(res.stdout)
        
        if res.succeeded {
            output?("-------------------------")
        } else {
            output?(res.stderror)
            output?("-------------------------")
            throw Error.fail(res.stderror)
        }
    }
    
    func close() throws {
        
    }
    
}
