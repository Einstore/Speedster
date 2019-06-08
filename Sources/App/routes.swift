import Fluent
import Vapor
import SpeedsterCore


/// Register your application's routes here.
public func routes(_ r: Routes, _ c: Container) throws {
    try Speedster.configure(routes: r, on: c)
}
