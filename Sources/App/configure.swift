import Fluent
import Vapor
import SpeedsterDB


/// Called before your application initializes.
public func configure(_ s: inout Services) throws {
    /// Register providers first
    s.provider(FluentProvider())

    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }
    
    let dbId = try Speedster.setup(database: &s)
    
    s.register(Migrations.self) { c in
        var migrations = Migrations()
        try SpeedsterDb.configure(migrations: &migrations, dbIdentifier: dbId)
        return migrations
    }
    
    try Speedster.configure(services: &s)
}
