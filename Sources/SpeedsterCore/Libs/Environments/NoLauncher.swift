import Fluent


final class NoLauncher: Launcher {
    
    let node: Row<Node>
    let e: EventLoop
    
    func launch(env: [String : String]?) -> EventLoopFuture<Root.Env.Connection> {
        let conn = Root.Env.Connection(
            host: node.host,
            port: node.port,
            auth: node.auth
        )
        return e.makeSucceededFuture(conn)
    }
    
    required init(_ env: Root.Env, node: Row<Node>, on eventLoop: EventLoop) throws {
        self.node = node
        e = eventLoop
    }
    
    func clean() -> EventLoopFuture<Void> {
        return e.makeSucceededFuture(Void())
    }
    
}
