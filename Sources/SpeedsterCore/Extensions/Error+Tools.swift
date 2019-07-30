import Fluent


extension Error {
    
    func fail<C>(_ eventLoop: EventLoop) -> EventLoopFuture<C> {
        return eventLoop.makeFailedFuture(self)
    }
    
    func fail<C>(_ container: Container) -> EventLoopFuture<C> {
        return fail(container.eventLoop)
    }
    
    func fail<C>(_ db: Database) -> EventLoopFuture<C> {
        return fail(db.eventLoop)
    }
    
}
