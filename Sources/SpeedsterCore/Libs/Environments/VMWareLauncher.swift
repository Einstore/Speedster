import Fluent
import VMWareRunKit


class VMWareLauncher: Launcher {
    
    let eventLoop: EventLoop
    
    let env: Root.Env
    let image: String
    
    let client: VMRun
    
    enum Error: Swift.Error {
        case imageDoesNotExist(String)
        case vmrestUnavailable
        case unableToLaunchImage
    }
    
    required init(_ env: Root.Env, node: Row<Node>, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.env = env
        client = try VMRun(
            node.asShellConnection(),
            for: .fusion,
            on: eventLoop
        )
        image = env.image.serialize().replacingOccurrences(of: "vmware;", with: "")
    }
    
    func launch(env: [String: String]? = nil) -> EventLoopFuture<Root.Env.Connection> {
        return createSpeedsterSnapshotIfNeeded().flatMap { _ in
            fatalError()
        }
    }
    
    func clean() -> EventLoopFuture<Void> {
        // Power off machine
        // Reset machine to Speedster snapshot
        fatalError()
    }
    
    // MARK: Private interface
    
    private func createSpeedsterSnapshotIfNeeded() -> EventLoopFuture<Void> {
        return client.send(command: .revertToSnapshot(image: image, name: "Speedster")).flatMap { output in
            print(output)
            fatalError()
        }
    }
    
}
