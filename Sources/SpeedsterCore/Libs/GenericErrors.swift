//
//  GenericErrors.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import Vapor


/// Generic HTTP error
public enum HTTPError: Error {
    
    /// Not found
    case notFound
    
    /// Missing query  or POST parameters
    case missingParamaters
    
}

/// Generic error
public enum GenericError: Error {
    
    /// Error decoding content
    case decodingError
    
    /// Missing expected data
    case missingParamater(String)
    
    /// Not supported
    case notSupported(String)
    
}

/// Generic error for work with database
public enum DbError: Error {
    
    /// Id of the object should have been known!
    case unknownId
    
}
