import Fluent


extension EventLoopFuture where Value == Void {
    
    public func asDeletedResponse(on c: Container) -> EventLoopFuture<Response> {
        return c.eventLoop.makeSucceededFuture(
            Response.make.deleted()
        )
    }
    
}
