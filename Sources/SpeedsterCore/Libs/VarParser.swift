import Foundation


public final class VarParser {
    
    let vars: [String: String]
    
    public init(vars: [String: String]) {
        self.vars = vars
    }
    
    public func parse(_ string: String) -> String {
        var string = string
        for v in vars {
            let token = "#{\(v.key)}"
            string = string.replacingOccurrences(of: token, with: v.value)
        }
        return string
    }
    
}
