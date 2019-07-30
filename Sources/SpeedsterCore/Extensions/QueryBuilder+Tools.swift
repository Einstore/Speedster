import Fluent


extension QueryBuilder {
    
    public func firstUnwrapped() -> EventLoopFuture<Row<Model>> {
        return first().unwrapOrNotFound()
    }
    
}
