import Foundation


extension String {
    
    func prepending(_ string: String) -> String {
        return "\(string)\(self)"
    }
    
    var prependingSpace: String {
        return prepending(" ")
    }
    
}
