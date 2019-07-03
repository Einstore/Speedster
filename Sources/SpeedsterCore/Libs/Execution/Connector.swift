//
//  Executor.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation


public typealias ConnectorOutput = ((_ output: String, _ jobName: String) -> ())


protocol Connector {
    
    var output: ConnectorOutput? { get set }

//    init(_ node: Root.Env.Connection, on eventLoop: EventLoop)
//    func run(_ phase: Root.Job.Phase, identifier: String) throws
//    func run(_ bash: String) throws -> Int
//    func close() throws
    
}
