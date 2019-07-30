import WebErrorKit
import ShellKit


/// Extension with commands
public struct Docker {
    
    public enum DockerError: String, WebError {
        
        case unsupportedPlatform
        
        public var statusCode: Int {
            return 412
        }
        
    }
    
    let shell: Shell
    
    init(_ shell: Shell) {
        self.shell = shell
    }
    
}


extension Shell {
    
    public var docker: Docker {
        return Docker(self)
    }
    
}


extension Docker {
    
    public var commandBuilder: DockerCommand {
        return DockerCommand()
    }
    
}
