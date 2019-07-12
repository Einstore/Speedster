//
//  RefRepo.swift
//  
//
//  Created by Ondrej Rafaj on 07/07/2019.
//

import ShellKit
import NIO


public class RefRepo {
    
    public enum Error: Swift.Error {
        case rsaValidationFailed(domain: String)
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
    
    public func clone(repo: String, checkout: String, for identifier: String) -> EventLoopFuture<String> {
        let repoPath = git(for: repo)
        
        return shell.exists(path: repoPath).flatMap { exists in
            func localCloneProcess() -> EventLoopFuture<String> {
                return self.clean(for: identifier).flatMap { _ in
                    return self.clone(repo: repo, to: identifier).flatMap { _ in
                        return self.checkout(identifier, to: checkout).map {
                            return self.tmp(identifier: identifier)
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
    
    public func clean(for identifier: String) -> EventLoopFuture<Void> {
        let path = tmp(identifier: identifier)
        return shell.rm(path: path, flags: "-rf").void()
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
    
    public func add(ssh key: String) -> EventLoopFuture<Void> {
        return shell.run(bash: "VAR=$'\(key)' ; echo -e $VAR | ssh-add - ; VAR='Nice try! :)') ").void()
    }
    
    // MARK: Private interface
    
    func run(bash command: String) -> EventLoopFuture<Void> {
        return shell.run(bash: command).map { out in
            print("Output for \(command): " + out)
        }
    }
    
    func clone(repo: String) -> EventLoopFuture<Void> {
        let path = tmp(for: repo)
        return run(bash: "git clone \(repo) \(path.quoteEscape)")
    }
    
    func clone(repo: String, to identifier: String) -> EventLoopFuture<Void> {
        let from = git(for: repo)
        let to = tmp(identifier: identifier)
        return run(bash: "git clone \(from.quoteEscape) \(to.quoteEscape)")
    }
    
    func fetch(repo: String) -> EventLoopFuture<Void> {
        let path = tmp(for: repo)
        return run(bash: "cd \(path) ; git fetch")
    }
    
    func checkout(_ identifier: String, to checkout: String) -> EventLoopFuture<Void> {
        let path = tmp(identifier: identifier)
        return run(bash: "cd \(path) ; git checkout \(checkout)")
    }
    
    func git(for repo: String) -> String {
        return tmp(for: repo.safeText).finished(with: "/").appending(".git")
    }
    
    func git(identifier: String) -> String {
        return tmp(identifier: identifier.safeText).finished(with: "/").appending(".git")
    }
    
    func tmp(for repo: String) -> String {
        return temp.finished(with: "/").appending("refs/").appending(repo.safeText)
    }
    
    func tmp(identifier: String) -> String {
        return temp.finished(with: "/").appending("clones/").appending(identifier.safeText)
    }
    
}
