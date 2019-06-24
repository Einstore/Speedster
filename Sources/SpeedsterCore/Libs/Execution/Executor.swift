//
//  Executor.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation


public typealias ExecutorOutput = ((_ output: String, _ identifier: String?) -> ())


protocol Executor {
    
    var output: ExecutorOutput? { get set }
    
    init(_ node: Node, on eventLoop: EventLoop)
    func run(_ phase: Root.Job.Phase, identifier: String) throws
    func run(_ bash: String) throws -> Int
    func close() throws
    
}
