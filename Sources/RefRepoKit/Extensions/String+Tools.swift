import Foundation


extension String {
    
    func finished(with string: String) -> String {
        if let last = last, String(last) == string {
            return self
        }
        return appending(string)
    }
    
    var escapedNewLines: String {
        return replacingOccurrences(of: "\n", with: "\\n")
    }
    
    var escapeSpaces: String {
        return replacingOccurrences(of: " ", with: "\\ ")
    }
    
    var safeText: String {
        var text = components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").inverted).joined(separator: "-").lowercased()
        text = text.components(separatedBy: CharacterSet(charactersIn: "-")).filter { !$0.isEmpty }.joined(separator: "-")
        return text
    }
    
}
