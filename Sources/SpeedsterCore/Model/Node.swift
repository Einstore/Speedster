//
//  Node.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import Vapor


// Node is a single worker machine to which Speedster connects via SSH
public struct Node: Model {
    
    public enum Auth: Int, Codable {
        case none = 0
        case me = 1
        case password = 2
        case privateKey = 3
    }
    
    public static let shared = Node()
    public static let entity = "nodes"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Node name
    public var name = Field<String>("name")
    
    /// Host (no protocol, ex. example.com)
    public var host = Field<String>("host")
    
    /// Port to connect to
    public var port = Field<Int?>("port")
    
    /// Port to connect to
    public var user = Field<String?>("user")
    
    /// Login password (if auth is 2) or an optional passphrase (if auth is 3)
    public var password = Field<String?>("password")
    
    /// Public key certificate
    public var publicKey = Field<String?>("public_key")
    
    /// Certificate passphrase
    public var passphrase = Field<String?>("passphrase")
    
    /// Authentication
    public var auth = Field<Auth>("auth", dataType: .int8)
    
    /// Max node runners
    public var maxRunners = Field<Int8>("max_runners")
    
    /// Node used count
    public var running = Field<Int8>("running")

}
