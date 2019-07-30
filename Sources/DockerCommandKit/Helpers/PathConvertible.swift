import Foundation


public protocol PathConvertible: Hashable, LosslessStringConvertible {
    var description: String { get }
}


extension String: PathConvertible { }
