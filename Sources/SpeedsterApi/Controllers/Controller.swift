//
//  Controller.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor
import Fluent


public protocol Controller {
    
    var db: Database { get }
    init(_ db: Database)
    func routes(_ r: Routes, _ c: Container) throws
    
}
