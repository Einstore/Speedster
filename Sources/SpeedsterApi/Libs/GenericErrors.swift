//
//  GenericErrors.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import Foundation


public enum HTTPError: Error {
    
    case notFound
    
}

/// Generic error for work with database
public enum DbError: Error {
    
    /// Id of the object should have been known!
    case unknownId
    
}
