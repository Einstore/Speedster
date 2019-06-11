//
//  String+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Foundation


extension Data {
    
    func asString() -> String {
        return String(data: self, encoding: .utf8) ?? ""
    }
    
}
