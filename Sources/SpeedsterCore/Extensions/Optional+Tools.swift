//
//  Optional+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 12/07/2019.
//

import Foundation


extension Optional where Wrapped == String {
    
    public var isVeryVeryEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
}


extension Optional where Wrapped == Data {
    
    public var isVeryVeryEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
}
