//
//  Launcher.swift
//  
//
//  Created by Ondrej Rafaj on 03/07/2019.
//

import Vapor


public protocol Launcher {
    
    func launch(env: [String: String]?) -> EventLoopFuture<Root.Env.Connection>
    func clean() -> EventLoopFuture<Void>
    
}
