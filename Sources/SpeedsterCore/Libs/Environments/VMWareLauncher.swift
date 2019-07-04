//
//  VMWareLauncher.swift
//  
//
//  Created by Ondrej Rafaj on 03/07/2019.
//

import Vapor
import VMWareRestKit


class VMWareLauncher: Launcher {
    
    let eventLoop: EventLoop
    
    let env: Root.Env
    let image: String
    
    let client: VMWareRest
    
    enum Error: Swift.Error {
        case vmrestUnavailable
        case unableToLaunchImage
    }
    
    required init(_ env: Root.Env, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.env = env
        client = try VMWareRest(
            VMWareRest.Config(
                username: "vmrest",
                password: "!asdfgH0",
                server: "http://127.0.0.1:8697"
            ),
            eventLoop: eventLoop
        )
        image = env.image.serialize().replacingOccurrences(of: "vmrest;", with: "")
    }
    
    func launch() -> EventLoopFuture<Root.Env.Connection> {
        fatalError()
    }
    
    func clean() -> EventLoopFuture<Void> {
        fatalError()
    }
    
}
