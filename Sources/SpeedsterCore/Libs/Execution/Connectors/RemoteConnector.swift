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
    
    func run(_ phase: Job.Phase) throws -> String {
        if let err = sshError {
            throw err
        }
        var value = ""
        if !phase.name.isEmpty {
            value.append("\(phase.name)\n")
        }
        if !phase.description.isEmpty {
            value.append("\(phase.description)\n")
        }
        value.append("$ \(phase.command)\n")
        
        do {
            let res = try ssh?.execute("cd \(node.dir) && \(phase.command)", output: { string in
                if !string.isEmpty {
                    value.append(string)
                    value.append("\n")
                }
            })
            value.append("\(res == 0 ? "Success" : "Failure")\n")
            value.append("-------------------------\n")
            return value
        } catch {
            value.append("Failure\n")
            value.append(error.localizedDescription)
            value.append("-------------------------\n")
            throw Error.fail(error.localizedDescription)
        }
    }
    
    func close() {
        
    }
    
}

