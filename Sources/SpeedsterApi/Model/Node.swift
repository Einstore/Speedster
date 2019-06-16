//
//  Node.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
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
    
    /// Labels to be used to identify build machines
    public let labels = Field<String?>("labels")
    
    /// Login password (if auth is 2) or an optional passphrase (if auth is 3)
    public let password = Field<[UInt8]?>("password", dataType: .data)
    
    /// Public key certificate
    public let publicKey = Field<[UInt8]?>("public_key", dataType: .data)
    
    /// Authentication
    ///
    ///     public enum Auth: String, Codable {
    ///         case none = "na"
    ///         case me = "me"
    ///         case password = "ps"
    ///         case privateKey = "pk"
    ///     }
    ///
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
        node.labels = "master"
        node.host = "localhost"
        node.port = 0
        node.auth = .none
        node.executors = 2
        node.running = 0
        return node
    }
    
}

extension Row where Model == Node {
    
    func update(from nodeData: Row<Node>) {
        self.name = nodeData.name
        self.host = nodeData.host
        self.port = nodeData.port
        self.user = nodeData.user
        self.labels = nodeData.labels
        self.executors = nodeData.executors
//        if let password = nodeData.password {
//            self.password = try? Secrets.encrypt(password)
//        } else {
//            self.password = nil
//        }
//        if let publicKey = nodeData.publicKey {
//            self.publicKey = try? Secrets.encrypt(publicKey)
//        } else {
//            self.publicKey = nil
//        }
    }
    
}
