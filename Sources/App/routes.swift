import Fluent
import Vapor
import SpeedsterCore


/// Register your application's routes here.
public func routes(_ r: Routes, _ c: Container) throws {
//    r.get("hello") { req -> String in
//        return "Hello, world!"
//    }
//
//    let todoController = try TodoController(db: c.make())
//    r.get("todos", use: todoController.index)
//    r.post("todos", use: todoController.create)
//    r.on(.DELETE, "todos", ":todoID", use: todoController.delete)

    try Speedster.configure(routes: r, on: c)
}
