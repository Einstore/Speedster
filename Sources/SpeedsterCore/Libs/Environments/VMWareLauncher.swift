//
//  VMWareLauncher.swift
//  
//
//  Created by Ondrej Rafaj on 03/07/2019.
//

import Foundation


class VMWareLauncher: Launcher {
    
    let env: Root.Env
    
    enum Error: Swift.Error {
        case vmrestUnavailable
    }
    
    required init(_ env: Root.Env) {
        self.env = env
    }
    
    func launch() -> EventLoopFuture<Root.Env.Connection> {
        fatalError()
    }
    
    func clean() -> EventLoopFuture<Void> {
        fatalError()
    }
    
}
