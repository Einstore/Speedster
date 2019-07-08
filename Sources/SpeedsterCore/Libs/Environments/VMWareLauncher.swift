//
//  VMWareLauncher.swift
//  
//
//  Created by Ondrej Rafaj on 03/07/2019.
//

import Fluent
import VMWareRunKit


class VMWareLauncher: Launcher {
    
    let eventLoop: EventLoop
    
    let env: Root.Env
    let image: String
    
    let vmrun: VMRun
    
    enum Error: Swift.Error {
        case imageDoesNotExist(String)
        case vmrestUnavailable
        case unableToLaunchImage
    }
    
    required init(_ env: Root.Env, node: Row<Node>, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.env = env
        vmrun = try VMRun(
            node.asShellConnection(),
            for: .fusion,
            on: eventLoop
        )
        image = env.image.serialize().replacingOccurrences(of: "vmware;", with: "")
    }
    
    func launch() -> EventLoopFuture<Root.Env.Connection> {
        do {
            return vmrun.send(command: .list).flatMap { machinesOutput in
                print(machinesOutput)
                fatalError()
//                let machines = []
//                guard let machine = machines.filter({ $0.path?.contains(self.image) ?? false }).first, let path = machine.path else {
//                    return Error.imageDoesNotExist(self.image).fail(self.eventLoop)
//                }
//                var output = ""
//                let outputClosure: ((String) -> ()) = { text in
//                    output += text
//                }
//                return self.vmrun.send(command: .listSnapshots(image: path), output: outputClosure).flatMap { exit in
//                    print(output)
//                    // Find snapshot called Speedster
//                    // Create Speedster snapshot if it desn't exist
//                    // Reset machine to Speedster snapshot
//                    // Launch Speedster
//
//                    fatalError()
//                }
            }
        } catch { return error.fail(self.eventLoop) }
    }
    
    func clean() -> EventLoopFuture<Void> {
        // Power off machine
        // Reset machine to Speedster snapshot
        fatalError()
    }
    
}
