//
//  Node.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import Vapor
import SpeedsterCore


// Node is a single worker machine to which Speedster connects via SSH
public struct Node: Model {
    
    public static let shared = Node()
    public static let entity = "nodes"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Node name
    public let name = Field<String>("name")
    
    /// Host (no protocol, ex. example.com)
    public let host = Field<String>("host")
    
    /// Port to connect to
    public let port = Field<Int?>("port")
    
    /// Port to connect to
    public let user = Field<String?>("user")
    
    /// Login password (if auth is 2) or an optional passphrase (if auth is 3)
    public let password = Field<String?>("password")
    
    /// Public key certificate
    public let publicKey = Field<String?>("public_key")
    
    /// Authentication
    public let auth = Field<SpeedsterCore.Node.Auth>("auth", dataType: .string)
    
    /// Max node runners
    public let executors = Field<Int>("executors")
    
    /// Node used count
    public let running = Field<Int?>("running")

}


extension Node {
    
    static func masterNode() -> Row<Node> {
        let node = Node.row()
        node.name = "Me"
        node.host = "localhost"
        node.port = 0
        node.auth = .none
        node.executors = 2
        node.running = 0
        return node
    }
    
}
