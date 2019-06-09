//
//  Controller.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor


public protocol Controller {
    
    func routes(_ r: Routes, _ c: Container) throws
    
}
