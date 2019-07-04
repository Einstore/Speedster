//
//  EnvironmentManager.swift
//  
//
//  Created by Ondrej Rafaj on 02/07/2019.
//

import Vapor


class EnvironmentManager {
    
    enum Error: Swift.Error {
        case errorInitializing(environment: Root.Env)
        case missingEnvironment(for: String)
    }
    
    let eventLoop: EventLoop
    
    init(on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    private var launcher: Launcher!
    
    // MARK: Public interface
    
    static func check(environments root: Root) throws {
        for job in root.jobs {
            if (job.environment ?? root.environment) == nil {
                throw Error.missingEnvironment(for: job.name)
            }
        }
    }
    
    func launch(environment env: Root.Env) -> EventLoopFuture<Root.Env.Connection> {
        do {
            switch env.image {
            case .VMWare:
                launcher = try VMWareLauncher(env, on: eventLoop)
            default:
                fatalError()
            }
        } catch {
            return eventLoop.makeFailedFuture(Error.errorInitializing(environment: env))
        }
        return launcher.launch()
    }
    
    func clean() -> EventLoopFuture<Void> {
        return launcher.clean()
    }
    
    // MARK: Private interface
    
    
}
