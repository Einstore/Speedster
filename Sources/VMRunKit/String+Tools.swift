//
//  String+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation


extension String {
    
    var escaped: String {
        if contains(" ") {
            return "\"\(self)\""
        } else {
            return self
        }
    }
    
}
