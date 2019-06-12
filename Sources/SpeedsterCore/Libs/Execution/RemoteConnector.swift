//
//  RemoteConnector.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Shout


class RemoteExecutor: Executor {
    
    enum Error: Swift.Error {
        case missingUsername
        case invalidConnection
        case fail(String)
        case notSupported
    }
    
    let node: Node
    
    let eventLoop: EventLoop
    
    var ssh: SSH?
    var sshError: Swift.Error?
    
    var output: ExecutorOutput?
    
    required init(_ node: Node, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.node = node
        
        do {
            ssh = try SSH(host: node.host, port: Int32(node.port))
            switch node.auth {
            case .password:
                guard let username = node.user else {
                    throw Error.missingUsername
                }
                let password = node.password ?? ""
                try ssh?.authenticate(username: username, password: password)
            default:
                throw Error.notSupported
            }
            try ssh?.execute("mkdir \(node.dir) && cd \(node.dir)")
        } catch {
            sshError = error
        }
    }
    
    func run(_ phase: Job.Workflow.Phase, identifier: String) throws {
        if let err = sshError {
            throw err
        }
        
        if !phase.name.isEmpty {
            output?("\(phase.name)")
        }
        if !phase.description.isEmpty {
            output?("\(phase.description)")
        }
        output?("$ \(phase.command)")
        
        do {
            let res = try ssh?.execute("cd \(node.dir) && \(phase.command)", output: { string in
                if !string.isEmpty {
                    output?(string)
                }
            })
            output?("\(res == 0 ? "Success" : "Failure")")
            output?("-------------------------")
        } catch {
            output?("Failure\n")
            output?(error.localizedDescription)
            output?("-------------------------")
            throw Error.fail(error.localizedDescription)
        }
    }
    
    func close() throws {
        try ssh?.execute("exit")
    }
    
}

