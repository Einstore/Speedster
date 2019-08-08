//
//  EnvironmentManager.swift
//  
//
//  Created by Ondrej Rafaj on 02/07/2019.
//

import Fluent


// TODO: Do we even need this class?!!!!!!!!!!!!!
class EnvironmentManager {
    
    enum Error: Swift.Error {
        case errorInitializing(environment: Root.Env)
        case missingEnvironment(for: String)
        case unknownError
    }
    
    let eventLoop: EventLoop
    
    private var launcher: Launcher?
    
    private var bootUpError: Swift.Error?
    
    init(_ env: Root.Env, node: Row<Node>, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        
        do {
            switch env.image {
            case .vmware:
                launcher = try VMWareLauncher(env, node: node, on: eventLoop)
            case .docker:
                launcher = try DockerLauncher(env, node: node, on: eventLoop)
            }
        } catch {
            bootUpError = error
        }
    }
    
    
    // MARK: Public interface
    
    static func check(environments root: Root) throws {
        for job in root.jobs {
            if (job.environment ?? root.environment) == nil {
                throw Error.missingEnvironment(for: job.name)
            }
        }
    }
    
    func launch(env: [String: String]? = nil) -> EventLoopFuture<Root.Env.Connection> {
        guard let launcher = launcher else {
            return eventLoop.makeFailedFuture(bootUpError ?? Error.unknownError)
        }
        return launcher.launch(env: env)
    }
    
    func launch(dependencies env: [String: String]?, for root: Root) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func clean() -> EventLoopFuture<Void> {
        guard let launcher = launcher else {
            return eventLoop.makeFailedFuture(bootUpError ?? Error.unknownError)
        }
        return launcher.clean()
    }
    
    // MARK: Private interface
    
    
}
