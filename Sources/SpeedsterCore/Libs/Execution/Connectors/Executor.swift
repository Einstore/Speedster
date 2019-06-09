//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation


public typealias ExecutorOutput = ((String) -> ())


protocol Executor {
    
    var output: ExecutorOutput { get }
    
    init(_ node: Node, on eventLoop: EventLoop, output: @escaping ExecutorOutput)
    func run(_ phase: Job.Phase) throws
    func close() throws
    
}
