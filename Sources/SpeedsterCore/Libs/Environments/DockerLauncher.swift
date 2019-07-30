import Fluent


class DockerLauncher: Launcher {
    
    let eventLoop: EventLoop
    
    let env: Root.Env
    let image: String
    
    
    enum Error: Swift.Error {
        
    }
    
    required init(_ env: Root.Env, node: Row<Node>, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.env = env
        
        image = env.image.serialize().replacingOccurrences(of: "docker;", with: "")
    }
    
    func launch(env: [String: String]? = nil) -> EventLoopFuture<Root.Env.Connection> {
        fatalError()
    }
    
    func clean() -> EventLoopFuture<Void> {
        // Power off machine
        // Reset machine to Speedster snapshot
        fatalError()
    }
    
}
