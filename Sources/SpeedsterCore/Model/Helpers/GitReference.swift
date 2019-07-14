//
//  GitReference.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

import Foundation


public struct GitReference: Codable {
    
    public enum RefType: String, Codable {
        case branch
        case commit
        case tag
    }
    
    public let value: String
    public let type: RefType
    
}
