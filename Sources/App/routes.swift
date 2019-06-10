import Fluent
import Vapor
import SpeedsterCore
import SpeedsterApi

/// Register your application's routes here.
public func routes(_ r: Routes, _ c: Container) throws {
    try SpeedsterController().routes(r, c)
    try Speedster.configure(routes: r, on: c)
}
