import Fluent
import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Fluent database to execute queries on.
    let db: Database
    
    /// Creates a new `TodoController`.
    init(db: Database) {
        self.db = db
    }

    /// Deletes a parameterized `Todo`.
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: self.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: self.db) }
            .transform(to: .ok)
    }
}
