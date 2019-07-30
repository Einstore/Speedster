import Foundation


extension String {
    
    func commaSeparatedArray() -> [String] {
        return split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
    }
    
}


extension Data {
    
    func asString() -> String {
        return String(data: self, encoding: .utf8) ?? ""
    }
    
}
