//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Foundation


protocol Executor {
    
    init(_ node: Node, on eventLoop: EventLoop)
    func run(_ phase: Job.Phase) throws -> String
    func close()
    
}
