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
    
    func run(_ phase: Root.Job.Phase, identifier: String) throws {
        let workdir = node.dir.finished(with: "/").appending(identifier)
        try FileManager.default.createDirectory(atPath: workdir, withIntermediateDirectories: true, attributes: nil)
        
        if let name = phase.name, !name.isEmpty {
            output?("\(name)", phase.identifier)
        }
        if let description = phase.description, !description.isEmpty {
            output?("\(description)", phase.identifier)
        }
        output?("$ \(phase.command)", phase.identifier)
        
        var context = CustomContext(main)
        context.currentdirectory = workdir
        let res = context.run(bash: phase.command)
        
        output?(res.stdout, phase.identifier)
        
        if res.succeeded {
            output?("-------------------------", phase.identifier)
        } else {
            output?(res.stderror, phase.identifier)
            output?("-------------------------", phase.identifier)
            throw Error.fail(res.stderror)
        }
    }
    
    func run(_ bash: String) throws -> Int {
        let context = CustomContext(main)
        let res = context.run(bash: bash)
        output?(res.stdout, nil)
        return res.exitcode
    }
    
    func close() throws {
        
    }
    
}
