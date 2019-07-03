//
//  RemoteConnector.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Shout


class RemoteConnector: Connector {
    
//    enum Error: Swift.Error {
//        case missingUsername
//        case invalidConnection
//        case fail(String)
//        case notSupported
//    }
//    
//    let conn: Root.Env.Connection
//    
//    let eventLoop: EventLoop
//    
//    var ssh: SSH?
//    var sshError: Swift.Error?
    
    var output: ConnectorOutput?
    
//    required init(_ conn: Root.Env.Connection, on eventLoop: EventLoop) {
//        self.eventLoop = eventLoop
//        self.conn = conn
//        
//        do {
//            ssh = try SSH(host: conn.host, port: Int32(conn.port))
//            switch conn.auth {
//            case .password:
//                guard let username = conn.user else {
//                    throw Error.missingUsername
//                }
//                let password = conn.password ?? ""
//                try ssh?.authenticate(username: username, password: password)
//            default:
//                throw Error.notSupported
//            }
//            try ssh?.execute("mkdir \(conn.dir) && cd \(conn.dir)")
//        } catch {
//            sshError = error
//        }
//    }
//    
//    func run(_ phase: Root.Job.Phase, identifier: String) throws {
//        if let err = sshError {
//            throw err
//        }
//        
//        if let name = phase.name, !name.isEmpty {
//            output?("\(name)", phase.identifier)
//        }
//        if let description = phase.description, !description.isEmpty {
//            output?("\(description)", phase.identifier)
//        }
//        output?("$ \(phase.command)", phase.identifier)
//        
//        do {
//            let res = try ssh?.execute("cd \(node.dir) && \(phase.command)", output: { string in
//                if !string.isEmpty {
//                    output?(string, phase.identifier)
//                }
//            })
//            output?("\(res == 0 ? "Success" : "Failure")", phase.identifier)
//            output?("-------------------------", phase.identifier)
//        } catch {
//            output?("Failure\n", phase.identifier)
//            output?(error.localizedDescription, phase.identifier)
//            output?("-------------------------", phase.identifier)
//            throw Error.fail(error.localizedDescription)
//        }
//    }
//    
//    func run(_ bash: String) throws -> Int {
//        guard let ssh = ssh else {
//            throw Error.fail("No SSH")
//        }
//        let res = try ssh.execute(bash, output: { string in
//            if !string.isEmpty {
//                output?(string, nil)
//            }
//        })
//        return Int(res)
//    }
//    
//    func close() throws {
//        try ssh?.execute("exit")
//    }
    
}

