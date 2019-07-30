import Fluent
import RefRepoKit
import CommandKit
import GitHubKit
import WebErrorKit


class Executioner {
    
    enum UpdateData {
        case started(job: Root.Job)
        case output(text: String, job: Root.Job? = nil)
        case finished(exit: Int, job: Root.Job)
        case environment(error: Swift.Error, job: Root.Job)
        case error(_ error: Swift.Error, job: Root.Job)
    }
    
    public enum ExecutionerError: SerializableWebError {
        case invalidCredentials(name: String)
        case missingPrivateKey(name: String)
        case unsupportedCommand(command: String, node: Row<Node>)
        
        public var statusCode: Int {
            return 412
        }
        
        public var serializedCode: String {
            switch self {
            case .invalidCredentials:
                return "invalid_credentials"
            case .missingPrivateKey:
                return "missing_private_key"
            case .unsupportedCommand:
                return "unsupported_command"
            }
        }
        
        public var reason: String? {
            switch self {
            case .invalidCredentials(name: let name):
                return "Invalid credentials: \(name)"
            case .missingPrivateKey(name: let name):
                return "Missing private key: \(name)"
            case .unsupportedCommand(command: let command, node: let node):
                return "Unsupported \(command) command on \(node.host)"
            }
        }
        
    }
    
    typealias Update = ((UpdateData) -> ())
    
    /// Job to be executed
    let root: Root
    let node: Row<Node>
    
    // Pripeline
    let trigger: Root.Pipeline.Trigger
    let location: GitLocation
    
    let eventLoop: EventLoop
    let db: Database
    let github: Github
    
    var update: Update
    
    var processed: [String] = []
    
    var randomId: String
    
    var vars: [String: String] = [:]
    
    // MARK: Public interface
    
    /// Initializer
    init(
        root: Root,
        trigger: Root.Pipeline.Trigger,
        location: GitLocation,
        node: Row<Node>,
        identifier: Speedster.DbIdType?,
        github: Github,
        on db: Database,
        update: @escaping Update
        ) {
        self.root = root
        self.trigger = trigger
        self.location = location
        self.update = update
        self.github = github
        self.db = db
        eventLoop = db.eventLoop
        self.node = node
        randomId = "\(identifier?.uuidString ?? "unknown-identifier")-\(root.name.safeText)-\(UUID().uuidString)".lowercased()
    }
    
    typealias FailedClosure = ((Swift.Error) -> ())
    
    /// Execute job
    func run() -> EventLoopFuture<Void> {
        make(update: .output(text: "Building \(root.name) on \(node.host)"))
        return ExecutionerError.invalidCredentials(name: "test woe").fail(eventLoop)
//        return prepareCodebase().flatMap { _ in
//            return self.launchJobs()
//        }
    }
    
    // MARK: Private interface
    
    /// Clone and download code if required
    private func prepareCodebase() -> EventLoopFuture<Void> {
        return verifyNodeSoftware().flatMap {
            do {
                let nodeConnection = try self.node.asShellConnection()
                let shell = try Shell(nodeConnection, on: self.eventLoop)
                
                let workspace = self.workspace()
                self.vars["WORKSPACE"] = workspace
                self.make(update: .output(text: "Creating workspace folder at \(workspace)"))
                let shared = workspace.finished(with: "/").appending("shared")
                self.vars["SHARED"] = shared
                self.make(update: .output(text: "Creating workspace shared folder at \(shared)"))
                return shell.cmd.mkdir(path: shared, flags: "-p").flatMap { _ in
                    func download() -> EventLoopFuture<Void> {
                        if self.root.source?.apiDownload == true {
                            return self.apiDownload(shell)
                        } else {
                            return self.eventLoop.makeSucceededFuture(Void())
                        }
                    }
                    if let referenceRepo = self.root.source?.referenceRepo {
                        return self.refRepo(referenceRepo, on: nodeConnection).flatMap { _ in
                            return download()
                        }
                    } else {
                        return download()
                    }
                }
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    /// Verify basic software like curl, git or docker is available on the node if needed
    private func verifyNodeSoftware() -> EventLoopFuture<Void> {
        make(update: .output(text: "Verify node has all neccessary software"))
        let nodeManager = NodesManager(db)
        return nodeManager.software(for: node).flatMap { software in
            let required = self.root.requiredSoftware()
            for command in required {
                if software.contains(where: { $0.key == command }) {
                    if software[command] == false {
                        return ExecutionerError.unsupportedCommand(command: command, node: self.node).fail(self.eventLoop)
                    }
                }
            }
            return self.eventLoop.makeSucceededFuture(Void())
        }
    }
    
    /// Download files using the Github API into workspace/downloaded
    private func apiDownload(_ shell: Shell) -> EventLoopFuture<Void> {
        make(update: .output(text: "Downloading source"))
        let destination = self.workspace(subItem: "downloaded")
        vars["DOWNLOADED"] = destination
        return shell.cmd.mkdir(path: destination, flags: "-p").flatMap { _ in
            do {
                return try self.github.download(org: self.location.org, repo: self.location.repo, ref: self.location.commit).flatMap { link in
                    let archive = self.workspace(subItem: "archive.tar")
                    return shell.run(bash: "curl -o \(archive) \(link)") { output in
                        self.make(update: .output(text: output))
                    }.future.flatMap { output in
                        return shell.run(bash: "tar -C \(destination) -xvf \(archive)") { output in
                            self.make(update: .output(text: output))
                        }.future.flatMap { _ in
                            let unarchived = destination
                                .finished(with: "/")
                                .appending("\(self.location.org)-\(self.location.repo)-\(self.location.commit)")
                            // Move files from a subfolder (if exists)
                            return shell.run(bash: "mv \(unarchived)/* \(destination) ; rm -rf \(unarchived)").future.map { output in
                                return Void()
                            }.always { _ in
                                self.make(update: .output(text: "Source available at \(destination)"))
                            }.recover { _ in
                                return Void()
                            }
                        }
                    }
                }
            } catch {
                return error.fail(self.eventLoop)
            }
        }
    }
    
    /// Clone files using a reference repo into workspace/cloned
    private func refRepo(_ referenceRepo: Root.Git.Reference, on conn: Shell.Connection) -> EventLoopFuture<Void> {
        do {
            let ref = try RefRepo(
                conn,
                temp: referenceRepo.path ?? "/tmp/speeedster/",
                on: eventLoop) { text in
                    self.make(update: .output(text: text))
            }
            
            func knownHosts() -> EventLoopFuture<Void> {
                func checkout() -> EventLoopFuture<Void> {
                    let destination = workspace(subItem: "cloned")
                    return ref.clone(
                        repo: referenceRepo.origin,
                        checkout: trigger.ref,
                        target: destination,
                        workspace: workspace()
                    ).map { path in
                        self.vars["CLONED"] = destination
                        return Void()
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
                    self.make(update: .output(text: "Adding ssh keys"))
                    guard creds.count == ssh.count else {
                        let diff = ssh.difference(from: creds.map { $0.name })
                        return ExecutionerError.invalidCredentials(name: diff.first ?? "unknown credentials").fail(self.eventLoop)
                    }
                    
                    func addPrivateKey(_ creds: [Row<Credentials>]) -> EventLoopFuture<Void> {
                        guard let cred = creds.first else {
                            return self.eventLoop.makeSucceededFuture(Void())
                        }
                        guard let privateKey = cred.privateKeyDecrypted else {
                            return ExecutionerError.missingPrivateKey(name: cred.name).fail(self.eventLoop)
                        }
                        return ref.add(ssh: privateKey, workspace: self.workspace()).flatMap { _ in
                            return addPrivateKey(Array(creds.dropFirst()))
                        }
                    }
                    
                    return addPrivateKey(creds).flatMap { _ in
                        return knownHosts()
                    }
                }
            } else {
                return knownHosts()
            }
        } catch {
            return error.fail(eventLoop)
        }
    }
    
    /// Launch jobs in their environments
    private func launchJobs() -> EventLoopFuture<Void> {
        make(update: .output(text: "Starting jobs"))
        var futures: [EventLoopFuture<Void>] = []
        for job in root.jobs.filter({ $0.dependsOn == nil || $0.dependsOn?.isEmpty == true }) {
            let future: EventLoopFuture<Void> = launch(envFor: job).flatMap { connection in
                fatalError()
            }
            futures.append(future)
        }
        return futures.flatten(on: eventLoop)
    }
    
    /// Launch an envitonment for a job
    private func launch(envFor job: Root.Job) -> EventLoopFuture<Root.Env.Connection> {
        // TODO: Launch a new Shell for each job as it will otherwise confuse shell->Channel over SSH!!!!!!!
        guard let env = job.environment ?? root.environment else {
            fatalError("Missing environment, this should have been checked before the run has started (favourite last words ... THIS SHOULD NEVER HAPPEN!)")
        }
        let envManager = EnvironmentManager(
            env,
            node: self.node,
            on: self.eventLoop
        )
        var envVars = root.scriptVariables ?? [:]
        if let vars = env.variables {
            for v in vars {
                envVars[v.key] = v.value
            }
        }
        return envManager.launch(env: envVars).always { result in
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
    
    /// Workspace path builder
    private func workspace(subItem item: String? = nil) -> String {
        var workspace = root.workspace ?? "/tmp/speeedster/workspaces"
        workspace = workspace.finished(with: "/").appending("\(randomId)")
        if let item = item {
            return workspace.finished(with: "/").appending(item)
        } else {
            return workspace
        }
    }
    
    /// Report event/output
    private func make(update data: UpdateData) {
        eventLoop.execute {
            self.update(data)
        }
    }
    
    deinit {
        // TODO: This neeeds to be called!!!!!!!!!!!!!!!
        print("Executioner deallocated :)")
    }
    
}
