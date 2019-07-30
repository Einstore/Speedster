import Fluent


public extension EventLoopFuture where Value: OptionalType {

    func unwrapOrNotFound() -> EventLoopFuture<Value.WrappedType> {
        return unwrap(or: HTTPError.notFound)
    }
    
}
