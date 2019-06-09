//
//  Speedster.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor


public class Speedster {
    
    public typealias DbIdType = UUID
    
    public static func configure(services s: inout Services) throws {
        
    }
    
    public static func configure(routes r: Routes, on c: Container) throws {
        let controller = SpeedsterController()
        try controller.routes(r, c)
    }
    
}
