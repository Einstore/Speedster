//
//  Branch.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Foundation


public struct Branch: Codable {
    
    public enum Action: Codable {
        
        public enum Error: Swift.Error {
            case decoding(String)
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            if let _ = try? values.decode(String.self, forKey: .commit) {
                self = .commit
                return
            }
            if let value = try? values.decode(String.self, forKey: .message) {
                self = .message(value)
                return
            }
            throw Error.decoding("Error decoding Action: \(dump(values))")
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .commit:
                try container.encode("commit", forKey: .commit)
            case .message(let value):
                try container.encode(value, forKey: .message)
            }
        }
        
        case commit
        
        case message(String)
        
        enum CodingKeys: String, CodingKey {
            case commit
            case message
        }
        
    }
    
    public let name: String
    
    public let action: Action
    
}
