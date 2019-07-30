import Vapor


public protocol Launcher {
    
    func launch(env: [String: String]?) -> EventLoopFuture<Root.Env.Connection>
    func clean() -> EventLoopFuture<Void>
    
}
