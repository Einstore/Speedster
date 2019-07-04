//
//  Executor.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import NIO


/// Executor protocol
public protocol Executor {
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    func run(bash: String, output: ((String) -> ())?) -> EventLoopFuture<Int32>
    
}
