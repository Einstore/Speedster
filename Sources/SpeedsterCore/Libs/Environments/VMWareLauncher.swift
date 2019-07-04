//
//  VMWareLauncher.swift
//  
//
//  Created by Ondrej Rafaj on 03/07/2019.
//

import Fluent
import VMWareRestKit
import VMWareRunKit


class VMWareLauncher: Launcher {
    
    let eventLoop: EventLoop
    
    let env: Root.Env
    let image: String
    
    let vmrest: VMWareRest
    let vmrun: VMRun
    
    enum Error: Swift.Error {
        case vmrestUnavailable
        case unableToLaunchImage
    }
    
    required init(_ env: Root.Env, node: Row<Node>, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.env = env
        vmrest = try VMWareRest(
            VMWareRest.Config(
                username: "vmrest",
                password: "!asdfgH0",
                server: "http://\(node.host):8697"
            ),
            eventLoop: eventLoop
        )
        vmrun = try VMRun(
            node.asShellConnection(),
            for: .fusion,
            on: eventLoop
        )
        image = env.image.serialize().replacingOccurrences(of: "vmware;", with: "")
    }
    
    func launch() -> EventLoopFuture<Root.Env.Connection> {
        // Check image exists
        // Check machine is off
        // Check image has Speedster-clean snapshot
        // Reset image to Speedster-clean snapshot if only Speedster-run exists
        // Rename snapshot to Speedster-run
        // Launch Speedster-run
        fatalError()
    }
    
    func clean() -> EventLoopFuture<Void> {
        // Power off machine
        // Reset Speedster-run to Speedster-clean snapshot
        // Rename snapshot to Speedster-clean
        fatalError()
    }
    
}
