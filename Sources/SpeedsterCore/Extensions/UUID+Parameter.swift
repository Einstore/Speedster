//
//  UUID+Parameter.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Foundation


extension UUID: LosslessStringConvertible {
    
    public init?(_ description: String) {
        self.init(uuidString: description)
    }
    
}
