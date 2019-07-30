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
