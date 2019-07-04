//
//  LocalExecutor.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import SwiftShell
import NIO


/// Local filesystem executor
public class LocalExecutor: Executor {
    
    let eventLoop: EventLoop
    let context: CustomContext
    
    
    /// Initializer
    /// - Parameter dir: Current working directory, defaults to `~/`
    /// - Parameter eventLoop: Event loop
    public init(workDir dir: String = "~/", on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        var context = CustomContext(main)
        context.currentdirectory = dir
        self.context = context
    }
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    public func run(bash: String, output: ((String) -> ())? = nil) -> EventLoopFuture<Int32> {
        let promise = eventLoop.makePromise(of: Int32.self)
        DispatchQueue.global(qos: .background).async {
            let out = self.context.runAsync(bash: bash)
            out.stdout.onStringOutput { text in
                output?(text)
            }
            out.onCompletion { cmd in
                promise.succeed(Int32(cmd.exitcode()))
            }
        }
        return promise.futureResult
    }
    
}
