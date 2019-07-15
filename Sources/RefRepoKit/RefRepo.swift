//
//  RefRepo.swift
//  
//
//  Created by Ondrej Rafaj on 07/07/2019.
//

import CommandKit
import NIO


public class RefRepo {
    
    public enum Error: Swift.Error {
        case rsaValidationFailed(domain: String)
        case onlyOneIdRsaKeySupported
        case sshKeyHasNotBeenSpecified
    }
    
    let shell: Shell
    let eventLoop: EventLoop
    
    let temp: String
    
    // MARK: Public interface
    
    public init(
        _ conn: Shell.Connection,
        temp: String = "/tmp",
        on eventLoop: EventLoop,
        output: ((String) -> ())?
        ) throws {
        shell = try Shell(conn, on: eventLoop)
        shell.output = { text in
            output?(text)
        }
        self.eventLoop = eventLoop
        self.temp = temp
    }
    
    public func clone(repo: String, checkout: String, workspace: String) -> EventLoopFuture<String> {
        let repoPath = git(for: repo)
        
        return shell.exists(path: repoPath).flatMap { exists in
            func localCloneProcess() -> EventLoopFuture<String> {
                return self.clean(for: workspace).flatMap { _ in
                    return self.clone(locally: repo, to: workspace).flatMap { _ in
                        return self.checkout(workspace, to: checkout).map {
                            return workspace
                        }
                    }
                }
            }
            
            if exists {
                return self.fetch(repo: repo).flatMap { out in
                    return localCloneProcess()
                }
            } else {
                return self.clone(repo: repo).flatMap { _ in
                    return localCloneProcess()
                }
            }
        }
    }
    
    public func clean(for workspace: String) -> EventLoopFuture<Void> {
        return shell.cmd.rm(path: workspace, flags: "-rf").void()
    }
    
    public func add(rsa arr: [(domain: String, sha: String?)]? = nil) -> EventLoopFuture<Void> {
        guard let arr = arr else {
            return eventLoop.makeSucceededFuture(Void())
        }
        
        func run(_ output: String) -> EventLoopFuture<Void> {
            var futures: [EventLoopFuture<Void>] = []
            for rsa in arr {
                if !output.contains(rsa.domain) {
                    let future: EventLoopFuture<Void> = self.shell.run(bash: "ssh-keyscan \(rsa.domain) >> \(rsa.domain.safeText) ; ssh-keygen -lf \(rsa.domain.safeText)").flatMap { output in
                        if let sha = rsa.sha, !output.contains(sha) {
                            return self.eventLoop.makeFailedFuture(Error.rsaValidationFailed(domain: rsa.domain))
                        }
                        return self.shell.run(bash: "cat \(rsa.domain.safeText) >> ~/.ssh/known_hosts").void()
                    }
                    futures.append(future)
                }
            }
            return futures.flatten(on: self.eventLoop)
        }
        
        return shell.run(bash: "cat ~/.ssh/known_hosts").flatMap { output in
            return run(output)
        }.flatMapError { error in
            return run("")
        }
    }
    
    var sshKeys: [String] = []
    
    public func add(ssh key: String, workspace: String) -> EventLoopFuture<Void> {
        guard sshKeys.count == 0 else {
            return eventLoop.makeFailedFuture(Error.onlyOneIdRsaKeySupported)
        }
        let name = "id_rsa.\(sshKeys.count)"
        return shell.upload(string: key, to: workspace.finished(with: "/").appending(name)).map { _ in
            self.sshKeys.append(name)
        }
    }
    
    // MARK: Private interface
    
    func run(bash command: String) -> EventLoopFuture<Void> {
        return shell.run(bash: command).map { out in
            print("Output for \(command): " + out)
        }
    }
    
    private func has(http repo: String) -> Bool {
        return repo.prefix(8) == "https://" || repo.prefix(7) == "http://"
    }
    
    func clone(repo: String) -> EventLoopFuture<Void> {
        let path = tmp(for: repo)
        if has(http: repo) {
            return run(bash: "git clone \(repo) \(path.quoteEscape)")
        } else {
            guard let key = sshKeys.first else {
                return eventLoop.makeFailedFuture(Error.sshKeyHasNotBeenSpecified)
            }
            return run(bash: "GIT_SSH_COMMAND='ssh -i /root/id_rsa' git clone \(repo) \(path.quoteEscape)")
        }
    }
    
    func clone(locally repo: String, to workspace: String) -> EventLoopFuture<Void> {
        let from = git(for: repo)
        return run(bash: "git clone \(from.quoteEscape) \(workspace.quoteEscape)")
    }
    
    func fetch(repo: String) -> EventLoopFuture<Void> {
        let path = tmp(for: repo)
        return run(bash: "cd \(path) ; git fetch")
    }
    
    func checkout(_ workspace: String, to checkout: String) -> EventLoopFuture<Void> {
        return run(bash: "cd \(workspace) ; git checkout \(checkout)")
    }
    
    func git(for repo: String) -> String {
        return tmp(for: repo.safeText).finished(with: "/").appending(".git")
    }
    
    func git(workspace: String) -> String {
        return workspace.finished(with: "/").appending(".git")
    }
    
    func tmp(for repo: String) -> String {
        return temp.finished(with: "/").appending("refs/").appending(repo.safeText)
    }
    
}
