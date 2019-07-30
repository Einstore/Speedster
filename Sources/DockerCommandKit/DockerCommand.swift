import ShellKit


public struct DockerCommand {
    
    public enum DisplaySize {
        case short
        case full
    }
    
    public enum RunMode: String {
        case interactive = "i"
        case detached = "d"
    }
    
    /// Attach local standard input, output, and error streams to a running container
    public func attach() -> String {
        fatalError("Not implemented")
    }
    
    /// Build an image from a Dockerfile
    public func build(
        file: String? = nil,
        tag: String? = nil,
        args: [String: String?] = [:],
        options: [String] = [],
        path: String = "."
    ) -> String {
        var out = "docker build"
        if let file = file {
            out.append(" -f \(file.quoteEscape)")
        }
        if let tag = tag {
            out.append(" -t \(tag)")
        }
        for arg in args {
            if let v = arg.value {
                out.append(" --build-arg \(arg.key)=\(v.quoteEscape)")
            } else {
                out.append(" --build-arg \(arg.key)")
            }
        }
        for o in options {
            out.append(o.prependingSpace)
        }
        out.append(path.prependingSpace)
        return out
    }
    
    /// Manage builds
    public func builder() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage checkpoints
    public func checkpoint() -> String {
        fatalError("Not implemented")
    }
    
    /// Create a new image from a container’s changes
    public func commit() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Docker configs
    public func config() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage containers
    public func container() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage contexts
    public func context() -> String {
        fatalError("Not implemented")
    }
    
    /// Copy files/folders between a container and the local filesystem
    public func cp() -> String {
        fatalError("Not implemented")
    }
    
    /// Create a new container
    public func create() -> String {
        fatalError("Not implemented")
    }
    
    /// Deploy a new stack or update an existing stack
    public func deploy() -> String {
        fatalError("Not implemented")
    }
    
    /// Inspect changes to files or directories on a container’s filesystem
    public func diff() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage the docker engine
    public func engine() -> String {
        fatalError("Not implemented")
    }
    
    /// Get real time events from the server
    public func events() -> String {
        fatalError("Not implemented")
    }
    
    /// Run a command in a running container
    public func exec() -> String {
        fatalError("Not implemented")
    }
    
    /// Export a container’s filesystem as a tar archive
    public func export() -> String {
        fatalError("Not implemented")
    }
    
    /// Show the history of an image
    public func history() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage images
    public func image() -> String {
        fatalError("Not implemented")
    }
    
    /// List images
    public func images() -> String {
        fatalError("Not implemented")
    }
    
    /// Import the contents from a tarball to create a filesystem image
    public func `import`() -> String {
        fatalError("Not implemented")
    }
    
    /// Display system-wide information
    public func info() -> String {
        fatalError("Not implemented")
    }
    
    /// Return low-level information on Docker objects
    public func inspect() -> String {
        fatalError("Not implemented")
    }
    
    /// Kill one or more running containers
    public func kill() -> String {
        fatalError("Not implemented")
    }
    
    /// Load an image from a tar archive or STDIN
    public func load() -> String {
        fatalError("Not implemented")
    }
    
    /// Log in to a Docker registry
    public func login() -> String {
        fatalError("Not implemented")
    }
    
    /// Log out from a Docker registry
    public func logout() -> String {
        fatalError("Not implemented")
    }
    
    /// Fetch the logs of a container
    public func logs() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Docker image manifests and manifest lists
    public func manifest() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage networks
    public func network() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Swarm nodes
    public func node() -> String {
        fatalError("Not implemented")
    }
    
    /// Pause all processes within one or more containers
    public func pause() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage plugins
    public func plugin() -> String {
        fatalError("Not implemented")
    }
    
    /// List port mappings or a specific mapping for the container
    public func port() -> String {
        fatalError("Not implemented")
    }
    
    /// List containers
    public func ps() -> String {
        fatalError("Not implemented")
    }
    
    /// Pull an image or a repository from a registry
    public func pull() -> String {
        fatalError("Not implemented")
    }
    
    /// Push an image or a repository to a registry
    public func push() -> String {
        fatalError("Not implemented")
    }
    
    /// Rename a container
    public func rename() -> String {
        fatalError("Not implemented")
    }
    
    /// Restart one or more containers
    public func restart() -> String {
        fatalError("Not implemented")
    }
    
    /// Remove one or more containers
    public func rm() -> String {
        fatalError("Not implemented")
    }
    
    /// Remove one or more images
    public func rmi() -> String {
        fatalError("Not implemented")
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
    /// - Returns: Compiled command
    public func run<P>(
        image: String,
        name: String? = nil,
        volumes: [P: String] = [:],
        workdir: String? = nil,
        clean: Bool = false,
        mode: RunMode? = nil,
        tty: Bool = false,
        expose: [Int] = [],
        options: [String] = [],
        env: [String: String?] = [:],
        envFile: String?,
        command: (command: String, args: [String])? = nil
    ) -> String where P: PathConvertible {
        var out = "docker run"
        if let name = name {
            out.append(" --name \(name.quoteEscape)")
        }
        for volume in volumes {
            out.append(" -v \(volume.key.description.quoteEscape) \(volume.value.quoteEscape)")
        }
        if let workdir = workdir {
            out.append(" -w \(workdir.quoteEscape)")
        }
        if clean {
            out.append(" -rm")
        }
        if let mode = mode {
            out.append(mode.rawValue.prepending(" -"))
        }
        if tty {
            out.append(" -t")
        }
        for ex in expose {
            out.append(" --expose \(ex)")
        }
        for o in options {
            out.append(o.prependingSpace)
        }
        for env in env {
            if let v = env.value {
                out.append(" -e \(env.key)=\(v.quoteEscape)")
            } else {
                out.append(" -e \(env.key)")
            }
        }
        if let c = command {
            out.append(c.command.prependingSpace)
            for arg in c.args {
                out.append(arg.prependingSpace)
            }
        }
        return out
    }
    
    /// Save one or more images to a tar archive (streamed to STDOUT by default)
    public func save() -> String {
        fatalError("Not implemented")
    }
    
    /// Search the Docker Hub for images
    public func search() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Docker secrets
    public func secret() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage services
    public func service() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Docker stacks
    public func stack() -> String {
        fatalError("Not implemented")
    }
    
    /// Start one or more stopped containers
    public func start() -> String {
        fatalError("Not implemented")
    }
    
    /// Display a live stream of container(s) resource usage statistics
    public func stats() -> String {
        fatalError("Not implemented")
    }
    
    /// Stop one or more running containers
    public func stop() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Swarm
    public func swarm() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage Docker
    public func system() -> String {
        fatalError("Not implemented")
    }
    
    /// Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
    public func tag() -> String {
        fatalError("Not implemented")
    }
    
    /// Display the running processes of a container
    public func top() -> String {
        fatalError("Not implemented")
    }
    
    /// Manage trust on Docker images
    public func trust() -> String {
        fatalError("Not implemented")
    }
    
    /// Unpause all processes within one or more containers
    public func unpause() -> String {
        fatalError("Not implemented")
    }
    
    /// Update configuration of one or more containers
    public func update() -> String {
        fatalError("Not implemented")
    }
    
    /// Show the Docker version information
    public func version(display: DisplaySize = .full) -> String {
        switch display {
        case .short:
            return "docker --version"
        default:
            return "docker version"
        }
    }
    
    /// Manage volumes
    public func volume() -> String {
        fatalError("Not implemented")
    }
    
    /// Block until one or more containers stop, then print their exit codes
    public func wait() -> String {
        fatalError("Not implemented")
    }
    
}
