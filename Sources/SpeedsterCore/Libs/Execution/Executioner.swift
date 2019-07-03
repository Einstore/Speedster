//
//  Executioner.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Fluent


class Executioner {
    
    enum UpdateData {
        case started(job: Root.Job)
        case output(text: String, job: Root.Job)
        case finished(exit: Int, job: Root.Job)
        case environment(error: Error, job: Root.Job)
        case error(_ error: Error, job: Root.Job)
    }
    
    typealias Update = ((UpdateData) -> ())
    
    /// Job to be executed
    let root: Root
    
    let eventLoop: EventLoop
    
    var update: Update
    
    var processed: [String] = []
    
    // MARK: Public interface
    
    /// Initializer
    init(root: Root, node: Row<Node>, on eventLoop: EventLoop, update: @escaping Update) {
        self.eventLoop = eventLoop
        self.root = root
        self.update = update
    }
    
     typealias FailedClosure = ((Swift.Error) -> ())
    
    /// Execute job
    func run(finished: @escaping (() -> ()), failed: @escaping FailedClosure) {
        for job in root.jobs.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
            // Launch virtual machine
            let envManager = EnvironmentManager(on: self.eventLoop)
            guard let env = job.environment ?? root.environment else {
                fatalError("Missing environment, this should have been checked before the run has started")
            }
            envManager.launch(environment: env).whenComplete { result in
                let connection: Root.Env.Connection
                switch result {
                case .success(let conn):
                    connection = conn
                case .failure(let error):
                    self.make(update: .environment(error: error, job: job))
                    return
                }
                DispatchQueue.global(qos: .background).async {
                    
                    fatalError()
                    
                    
//                    var executor = RemoteExecutor(connection, on: eventLoop)
//                    
//                    executor.output = { out, identifier in
//                        let out = "[\(connection.host)] \(out)"
//                        eventLoop.execute {
//                            self.output?(out, identifier)
//                        }
//                    }
//                    do {
//                        try self.run(job: job, failed: failed)
//                        if let success = job.success {
//                            for p in success {
//                                try executor.run(p, identifier: root.workspaceName)
//                            }
//                        }
//                        if let always = job.always {
//                            for p in always {
//                                try executor.run(p, identifier: root.workspaceName)
//                            }
//                        }
//                    } catch {
//                        if let fail = job.fail {
//                            for p in fail {
//                                try? executor.run(p, identifier: root.workspaceName)
//                            }
//                        }
//                        //throw error
//                    }
                }
            }
        }
    }
    
    func run(bash: String, finished: @escaping (() -> ()), failed: @escaping FailedClosure) {
        fatalError()
//        DispatchQueue.global(qos: .background).async {
//            do {
//                let res = try executor.run(bash)
//                guard res == 0 else {
//                    self.eventLoop.execute {
//                        failed(Error.nonZeroExit)
//                    }
//                    return
//                }
//                self.eventLoop.execute {
//                    finished()
//                }
//                try executor.close()
//            } catch {
//                self.eventLoop.execute {
//                    failed(error)
//                }
//                try? executor.close()
//            }
//        }
    }
    
    // MARK: Private interface
    
    private func make(update data: UpdateData) {
        eventLoop.execute {
            self.update(data)
        }
    }
    
    private func run(job: Root.Job, executor: Connector, failed: @escaping FailedClosure) throws {
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
    }
    
    deinit {
        // TODO: This neeeds to be called!!!!!!!!!!!!!!!
        print(":)")
    }
    
}
