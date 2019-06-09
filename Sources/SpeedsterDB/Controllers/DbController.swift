//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Fluent
import SpeedsterCore


public protocol DbController: Controller {
    
    var db: Database { get }
    init(_ db: Database)
    
}
