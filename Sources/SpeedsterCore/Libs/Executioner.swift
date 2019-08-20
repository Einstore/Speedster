import Fluent
import RefRepoKit
import CommandKit
import GitHubKit
import WebErrorKit


class Executioner {
    
    enum UpdateData {
        
        case started(job: Root.Job)
        // TODO: Make job `nil` by default again when it get's fixed in Swift SR-11256
        case output(text: String, job: Root.Job?)
        case finished(exit: Int, job: Root.Job)
        case environment(error: Swift.Error, job: Root.Job)
        case error(_ error: Swift.Error, job: Root.Job)
        
        // TODO: Remove as per previous comment
        public static func output(text: String) -> UpdateData {
            return .output(text: text, job: nil)
        }
        
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
        //        return ExecutionerError.invalidCredentials(name: "test woe").fail(eventLoop)
        return prepareCodebase().flatMap { _ in
            return self.launchJobs()
        }
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
            var envVars = root.scriptVariables ?? [:]
            if let env = job.environment ?? root.environment {
                // Add environments env vars
                if let vars = env.variables {
                    for v in vars {
                        envVars[v.key] = v.value
                    }
                }
                print(envVars)
                // TODO: Launch dependencies with access to vars
                let future: EventLoopFuture<Void> = launch(env, vars: envVars, for: job).flatMap { connection in
                    return self.execute(job, with: envVars, on: connection)
                }
                futures.append(future)
            } else {
                print(envVars)
                let future = self.execute(job, with: envVars)
                futures.append(future)
            }
        }
        return futures.flatten(on: eventLoop)
    }
    
    /// Launch an envitonment for a job
    private func launch(_ env: Root.Env, vars: [String: String], for job: Root.Job) -> EventLoopFuture<Root.Env.Connection> {
        let envManager = EnvironmentManager(
            env,
            node: self.node,
            on: self.eventLoop
        )
        return envManager.launch(dependencies: vars, for: root).flatMap { _ in
            return envManager.launch(env: vars).always { result in
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
    }
    
    /// Execute a job on a local machine or a connection to a VM
    ///     - Note: Do we want to allow this on Docker containers?!???
    private func execute(_ job: Root.Job, with vars: [String: String], on conn: Root.Env.Connection? = nil) -> EventLoopFuture<Void> {
        let shell: Shell
        let identifier: String
        do {
            if let conn = conn {
                shell = try Shell(
                    // TODO: Make a proper connection to the VM
                    .ssh(host: conn.host, username: "root", password: "aaaaaa"),
                    on: eventLoop
                )
            } else {
                shell = try Shell(.local, on: eventLoop)
            }
            identifier = try MD5.hash(.string("\(job)")).string()
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        processed.append(identifier)
        
        func append(_ phase: Root.Job.Phase, _ script: inout String) {
            script.append("\(phase.identifier ?? "")/n")
            script.append("\(phase.description ?? "")/n")
            script.append(phase.command)
        }
        
        func internalExecute(_ job: Root.Job) -> EventLoopFuture<Void> {
            var script = ""
            
            for phase in job.preBuild {
                append(phase, &script)
            }
            for phase in job.build {
                append(phase, &script)
            }
            for phase in job.success ?? [] {
                append(phase, &script)
            }
            
            // TODO: Parse vars into phase!!!!!!!!
            
            return shell.run(bash: script) { output in
                // TODO: Track output on redis
            }.future.flatMap { _ in // Process any sub-jobs
                do {
                    var futures: [EventLoopFuture<Void>] = []
                    for job in self.root.jobs.filter({ $0.dependsOn == job.name }) {
                        let identifier = try MD5.hash(.string("\(job)")).string()
                        if !self.processed.contains(identifier) {
                            let future = internalExecute(job)
                            futures.append(future)
                        }
                    }
                    return futures.flatten(on: self.eventLoop)
                } catch {
                    return self.eventLoop.makeFailedFuture(error)
                }
            }
        }
        
        return internalExecute(job).flatMapError { error in
            var futures: [EventLoopFuture<Void>] = []
            for phase in job.fail ?? [] {
                // TODO: Parse vars into phase!!!!!!!!
                let future = shell.run(bash: phase.command, output: { output in
                    // TODO: Track output on redis
                })
                futures.append(future.future.void())
            }
            return futures.flatten(on: self.eventLoop).flatMap { _ in
                return self.eventLoop.makeFailedFuture(error)
            }.flatMapError { _ in
                return self.eventLoop.makeFailedFuture(error)
            }
        }.flatMap { _ in
            var script = ""
            // TODO: Parse vars into phase!!!!!!!!
            for phase in job.always ?? [] {
                append(phase, &script)
            }
            return shell.run(bash: script) { output in
                // TODO: Track output on redis
            }.future.void()
        }
    }
    
    /// Workspace path builder
    private func workspace(subItem item: String? = nil) -> String {
        // TODO: Allow users to define their own workspace through ENV vars!!!!
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
