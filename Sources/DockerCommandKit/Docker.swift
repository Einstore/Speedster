import Foundation


extension Docker {
    
    /// Attach local standard input, output, and error streams to a running container
    public func attach() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Build an image from a Dockerfile
    public func build(
        file: String? = nil,
        tag: String? = nil,
        args: [String: String?] = [:],
        options: [String] = [],
        path: String = ".",
        output: ((String) -> ())? = nil
    ) -> EventLoopFuture<Void> {
        let c = cmd.build(
            file: file,
            tag: tag,
            args: args,
            options: options,
            path: path
        )
        return shell.run(bash: c, output: output).future.void()
    }
    
    /// Manage builds
    public func builder() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage checkpoints
    public func checkpoint() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Create a new image from a container’s changes
    public func commit() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Docker configs
    public func config() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage containers
    public func container() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage contexts
    public func context() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Copy files/folders between a container and the local filesystem
    public func cp() -> EventLoopFuture<[String]> {
        fatalError("Not implemented")
    }
    
    /// Create a new container
    public func create() -> EventLoopFuture<[String]> {
        fatalError("Not implemented")
    }
    
    /// Deploy a new stack or update an existing stack
    public func deploy() -> EventLoopFuture<[String]> {
        fatalError("Not implemented")
    }
    
    /// Inspect changes to files or directories on a container’s filesystem
    public func diff() -> EventLoopFuture<[String]> {
        fatalError("Not implemented")
    }
    
    /// Manage the docker engine
    public func engine() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Get real time events from the server
    public func events() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Run a command in a running container
    public func exec() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Export a container’s filesystem as a tar archive
    public func export() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Show the history of an image
    public func history() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage images
    public func image() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// List images
    public func images() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Import the contents from a tarball to create a filesystem image
    public func `import`() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Display system-wide information
    public func info() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Return low-level information on Docker objects
    public func inspect() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Kill one or more running containers
    public func kill() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Load an image from a tar archive or STDIN
    public func load() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Log in to a Docker registry
    public func login() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Log out from a Docker registry
    public func logout() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Fetch the logs of a container
    public func logs() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Docker image manifests and manifest lists
    public func manifest() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage networks
    public func network() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Swarm nodes
    public func node() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Pause all processes within one or more containers
    public func pause() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage plugins
    public func plugin() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// List port mappings or a specific mapping for the container
    public func port() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// List containers
    public func ps() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Pull an image or a repository from a registry
    public func pull() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Push an image or a repository to a registry
    public func push() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Rename a container
    public func rename() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Restart one or more containers
    public func restart() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Remove one or more containers
    public func rm() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Remove one or more images
    public func rmi() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    public enum Path: String, PathConvertible {
        
        case pwd = "$PWD"
        
        public var description: String{
            return rawValue
        }
        
        public init?(_ description: String) {
            self.init(rawValue: description)
        }
        
    }
    
    /// Run a command in a new container
    /// - Parameter image: Image
    /// - Parameter name: Assign a name to the container
    /// - Parameter volumes: Bind mount a volume (local: container)
    /// - Parameter workdir: Working directory inside the container
    /// - Parameter clean: Automatically remove the container when it exits
    /// - Parameter mode: Interactive (-i) or detached (-d)
    /// - Parameter tty: Allocate a pseudo-TTY
    /// - Parameter expose: Expose a port or a range of ports
    /// - Parameter options: Any additional options
    /// - Parameter env: Environmental variables
    /// - Parameter envFile: Read in a local file of environment variables
    /// - Parameter command: Command
    /// - Parameter output: Output (stdout)
    /// - Returns: stdout
    public func run<P>(
        image: String,
        name: String? = nil,
        volumes: [P: String] = [:],
        workdir: String? = nil,
        clean: Bool = false,
        mode: DockerCommand.RunMode? = nil,
        tty: Bool = false,
        expose: [Int] = [],
        options: [String] = [],
        env: [String: String] = [:],
        envFile: String?,
        command: (command: String, args: [String])? = nil,
        output: ((String) -> ())? = nil
    ) -> EventLoopFuture<String> where P: PathConvertible {
        let c = cmd.run(
            image: image,
            name: name,
            volumes: volumes,
            workdir: workdir,
            clean: clean,
            mode: mode,
            tty: tty,
            expose: expose,
            options: options,
            env: env,
            envFile: envFile,
            command: command
        )
        return shell.run(bash: c, output: output).future
    }
    
    /// Save one or more images to a tar archive (streamed to STDOUT by default)
    public func save() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Search the Docker Hub for images
    public func search() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Docker secrets
    public func secret() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage services
    public func service() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Docker stacks
    public func stack() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Start one or more stopped containers
    public func start() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Display a live stream of container(s) resource usage statistics
    public func stats() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Stop one or more running containers
    public func stop() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Swarm
    public func swarm() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage Docker
    public func system() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
    public func tag() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Display the running processes of a container
    public func top() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Manage trust on Docker images
    public func trust() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Unpause all processes within one or more containers
    public func unpause() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Update configuration of one or more containers
    public func update() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Show the Docker version
    public func v() -> EventLoopFuture<String> {
        let c = cmd.version(display: .short)
        return run(c)
    }
    
    /// Show the full Docker version information
    public func version() -> EventLoopFuture<String> {
        let c = cmd.version(display: .full)
        return run(c)
    }
    
    /// Manage volumes
    public func volume() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
    /// Block until one or more containers stop, then print their exit codes
    public func wait() -> EventLoopFuture<Void> {
        fatalError("Not implemented")
    }
    
}


extension Docker {
    
    fileprivate var cmd: DockerCommand {
        return shell.docker.commandBuilder
    }
    
    fileprivate func run(_ cmd: String) -> EventLoopFuture<String> {
        return shell.run(bash: cmd).future.map { output in
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
}
