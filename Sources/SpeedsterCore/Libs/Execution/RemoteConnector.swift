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
    
    let node: Machine
    
    let eventLoop: EventLoop
    
    var ssh: SSH?
    var sshError: Swift.Error?
    
    var output: ExecutorOutput?
    
    required init(_ node: Machine, on eventLoop: EventLoop) {
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
    
    func run(_ phase: Root.Job.Phase, identifier: String) throws {
        if let err = sshError {
            throw err
        }
        
        if let name = phase.name, !name.isEmpty {
            output?("\(name)", phase.identifier)
        }
        if let description = phase.description, !description.isEmpty {
            output?("\(description)", phase.identifier)
        }
        output?("$ \(phase.command)", phase.identifier)
        
        do {
            let res = try ssh?.execute("cd \(node.dir) && \(phase.command)", output: { string in
                if !string.isEmpty {
                    output?(string, phase.identifier)
                }
            })
            output?("\(res == 0 ? "Success" : "Failure")", phase.identifier)
            output?("-------------------------", phase.identifier)
        } catch {
            output?("Failure\n", phase.identifier)
            output?(error.localizedDescription, phase.identifier)
            output?("-------------------------", phase.identifier)
            throw Error.fail(error.localizedDescription)
        }
    }
    
    func run(_ bash: String) throws -> Int {
        guard let ssh = ssh else {
            throw Error.fail("No SSH")
        }
        let res = try ssh.execute(bash, output: { string in
            if !string.isEmpty {
                output?(string, nil)
            }
        })
        return Int(res)
    }
    
    func close() throws {
        try ssh?.execute("exit")
    }
    
}

