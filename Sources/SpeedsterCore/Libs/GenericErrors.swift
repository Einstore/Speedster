import Vapor
import WebErrorKit


/// Generic HTTP error
public enum HTTPError: SerializableWebError {
    
    /// Not found
    case notFound
    
    /// Missing query  or POST parameters
    case missingParamaters
    
    public var serializedCode: String {
        switch self {
        case .notFound:
            return "not_found"
        case .missingParamaters:
            return "missing_params"
        }
    }
    
}

/// Generic error
public enum GenericError: SerializableWebError {
    
    /// Error decoding content
    case decodingError(String?)
    
    /// Missing expected data
    case missingParamater(String)
    
    /// Not supported
    case notSupported(String)
    
    public var serializedCode: String {
        switch self {
        case .decodingError:
            return "decoring_error"
        case .missingParamater:
            return "missing_parameter"
        case .notSupported:
            return "not_supported"
        }
    }
    
}

/// Generic error for work with database
public enum DbError: Error {
    
    /// Id of the object should have been known!
    case unknownId
    
}
