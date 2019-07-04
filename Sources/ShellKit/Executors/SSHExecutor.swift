//
//  SSHExecutor.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import Shout
import NIO


/// SSH executor
public class SSHExecutor: Executor {
    
    let eventLoop: EventLoop
    let ssh: SSH
    
    let workDir: String
    
    /// Initializer
    /// - Parameter dir: Current working directory, defaults to `~/`
    /// - Parameter host: SSH host
    /// - Parameter port: SSH port
    /// - Parameter username: Login username
    /// - Parameter auth: Authentication
    /// - Parameter loop: Event loop
    public init(workDir dir: String = "~/", host: String, port: Int = 22, username: String, auth: SSHAuthMethod, on loop: EventLoop) throws {
        workDir = dir
        eventLoop = loop
        ssh = try SSH(host: host, port: Int32(port))
        try ssh.authenticate(username: username, authMethod: auth)
    }
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    public func run(bash: String, output: ((String) -> ())? = nil) -> EventLoopFuture<Int32> {
        let promise = eventLoop.makePromise(of: Int32.self)
        DispatchQueue.global(qos: .background).async {
            do {
                let output = output ?? { _ in }
                let res = try self.ssh.execute("cd \(self.workDir) ; \(bash)", output: output)
                promise.succeed(res)
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
    
}
