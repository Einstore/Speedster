//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Fluent
import RefRepoKit
import ShellKit


class Executioner {
    
    enum UpdateData {
        case started(job: Root.Job)
        case output(text: String, job: Root.Job? = nil)
        case finished(exit: Int, job: Root.Job)
        case environment(error: Swift.Error, job: Root.Job)
        case error(_ error: Swift.Error, job: Root.Job)
    }
    
    public enum Error: Swift.Error {
        case invalidCredentials(name: String)
        case missingPrivateKey(name: String)
    }
    
    typealias Update = ((UpdateData) -> ())
    
    /// Job to be executed
    let root: Root
    let node: Row<Node>
    
    // Pripeline
    let trigger: Root.Pipeline.Trigger
    
    let eventLoop: EventLoop
    let db: Database
    
    var update: Update
    
    var processed: [String] = []
    
    var randomId: String
    
    // MARK: Public interface
    
    /// Initializer
    init(
        root: Root,
        trigger: Root.Pipeline.Trigger,
        node: Row<Node>,
        on db: Database,
        update: @escaping Update
        ) {
        self.root = root
        self.trigger = trigger
        self.update = update
        self.db = db
        eventLoop = db.eventLoop
        self.node = node
        randomId = "\(root.name.safeText)-\(UUID().uuidString)".lowercased()
    }
    
     typealias FailedClosure = ((Swift.Error) -> ())
    
    /// Execute job
    func run() -> EventLoopFuture<Void> {
        guard let referenceRepo = root.source?.referenceRepo else {
            return run()
        }
        do {
            let nodeConnection = try node.asShellConnection()
            let ref = try RefRepo(
                nodeConnection,
                temp: referenceRepo.path ?? "/tmp/speeedster/",
                on: eventLoop) { text in
                    self.make(update: .output(text: text))
            }
            
            
            func knownHosts() -> EventLoopFuture<Void> {
                func checkout() -> EventLoopFuture<Void> {
                    return ref.clone(
                        repo: referenceRepo.origin,
                        checkout: trigger.branch,
                        for: randomId
                    ).flatMap { path in
                        return self.run(repoPath: path)
                    }
                }
                
                if let rsa = referenceRepo.rsa {
                    // Add RSA keys to ~/.known_hosts if neccessary
                    return ref.add(rsa: rsa.map({ (domain: $0, sha: $1) })).flatMap { _ in
                        return checkout()
                    }
                } else {
                    return checkout()
                }
            }
            
            if let ssh = referenceRepo.ssh {
                // Import ssh private keys to ~/.ssh/known_hosts
                return Credentials.select(name: ssh, on: self.db).all().flatMap { creds in
                    guard creds.count != ssh.count else {
                        let diff = ssh.difference(from: creds.map { $0.name })
                        return Error.invalidCredentials(name: diff.first ?? "unknown credentials").fail(self.eventLoop)
                    }
                    var futures: [EventLoopFuture<Void>] = []
                    for cred in creds {
                        guard let privateKey = cred.privateKeyDecrypted else {
                            return Error.missingPrivateKey(name: cred.name).fail(self.eventLoop)
                        }
                        let future = ref.add(ssh: privateKey).flatMap { _ in
                            return knownHosts()
                        }
                        futures.append(future)
                    }
                    return futures.flatten(on: self.eventLoop)
                }
            } else {
                return knownHosts()
            }
        } catch {
            return error.fail(eventLoop)
        }
    }
    
    // MARK: Private interface
    
    private func run(repoPath: String? = nil) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for job in root.jobs.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
            let future: EventLoopFuture<Void> = launch(envFor: job).flatMap { connection in
                fatalError()
            }
            futures.append(future)
        }
        return futures.flatten(on: eventLoop)
    }
    
    private func make(update data: UpdateData) {
        eventLoop.execute {
            self.update(data)
        }
    }
    
    private func launch(envFor job: Root.Job) -> EventLoopFuture<Root.Env.Connection> {
        guard let env = job.environment ?? root.environment else {
            fatalError("Missing environment, this should have been checked before the run has started (favourite last words ... THIS SHOULD NEVER HAPPEN!)")
        }
        let envManager = EnvironmentManager(env, node: self.node, on: self.eventLoop)
        return envManager.launch().always { result in
            let connection: Root.Env.Connection
            switch result {
            case .success(let conn):
                connection = conn
            case .failure(let error):
                self.make(update: .environment(error: error, job: job))
                return
            }
            print(connection)
        }
    }
    
//    private func run(job: Root.Job, failed: @escaping FailedClosure) throws {
//        guard let root = self.root else {
//            throw Error.missingJob
//        }
//        let identifier = try MD5.hash(.string("\(job)"))
//        processed.append("\(identifier.string())")
//        do {
//            for phase in job.preBuild {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for phase in job.build {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for phase in job.success ?? [] {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for phase in job.always ?? [] {
//                try executor.run(phase, identifier: root.workspaceName)
//            }
//            for workflow in root.jobs.filter({ $0.dependsOn == job.name }) {
//                let identifier = try MD5.hash(.string("\(workflow)"))
//                if !processed.contains(identifier.string()) {
//                    try self.run(job: workflow, failed: failed)
//                }
//            }
//        } catch {
//            do {
//                for phase in job.fail ?? [] {
//                    try executor.run(phase, identifier: root.workspaceName)
//                }
//            } catch {
//                eventLoop.execute {
//                    failed(error)
//                }
//                return
//            }
//            eventLoop.execute {
//                failed(error)
//            }
//        }
//    }
    
    deinit {
        // TODO: This neeeds to be called!!!!!!!!!!!!!!!
        print(":)")
    }
    
}
