//
//  GitLocation.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

import Foundation


public struct GitLocation: Codable {
    
    public let org: String
    public let repo: String
    public let commit: String
    
}


extension GitLocation {
    
    func compileSSH(server: String) -> String {
        return "git@\(server):\(org)/\(repo).git"
    }
    
}
