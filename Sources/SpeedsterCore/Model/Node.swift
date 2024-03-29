//
//  Node.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import SecretsKit


// Machine is a single worker machine to which Speedster connects via SSH
public struct Node: Model {
    
    public struct Post: Codable {
        
        let name: String
        let host: String
        let port: Int?
        let user: String?
        let labels: [String]?
        let password: String?
        let privateKey: String?
        let auth: Root.Env.Connection.Auth
        let executors: Int
        
        enum CodingKeys: String, CodingKey {
            case name
            case host
            case port
            case user
            case labels
            case password
            case privateKey = "public_key"
            case auth
            case executors
        }
        
    }
    
    public struct Display: Content {
        
        public let id: Speedster.DbIdType?
        public let name: String
        public let host: String
        public let port: Int?
        public let user: String?
        public let labels: [String]?
        public let password: Bool
        public let privateKey: Bool
        public let auth: Root.Env.Connection.Auth
        public let executors: Int
        public let running: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case host
            case port
            case user
            case labels
            case password
            case privateKey = "public_key"
            case auth
            case executors
            case running
        }
        
        public init(_ row: Row<Node>) {
            self.id = row.id
            self.name = row.name
            self.host = row.host
            self.port = row.port
            self.user = row.user ?? (row.auth == .password ? "root" : nil)
            self.labels = row.labels?.commaSeparatedArray()
            self.password = (row.password?.count ?? 0) > 0
            self.privateKey = (row.privateKey?.count ?? 0) > 0
            self.auth = row.auth
            self.executors = row.executors
            self.running = row.running
        }
        
    }
    
    public static let shared = Node()
    public static let entity = "nodes"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Node name
    public let name = Field<String>("name")
    
    /// Host (no protocol, ex. example.com)
    public let host = Field<String>("host")
    
    /// Port to connect to
    public let port = Field<Int>("port")
    
    /// Port to connect to
    public let user = Field<String?>("user")
    
    /// Labels to be used to identify build machines
    public let labels = Field<String?>("labels")
    
    /// Login password (if auth is 2) or an optional passphrase (if auth is 3)
    public let password = Field<Data?>("password", dataType: .data)
    
    /// Public RSA key
    //public let privateKey = Field<Data?>("public_key", dataType: .data)
    
    /// Private RSA key
    public let privateKey = Field<Data?>("private_key", dataType: .data)
    
    /// Authentication
    ///
    ///     public enum Auth: String, Codable {
    ///         case none = "na"
    ///         case me = "me"
    ///         case password = "ps"
    ///         case privateKey = "pk"
    ///     }
    ///
    public let auth = Field<Root.Env.Connection.Auth>("auth", dataType: .string)
    
    /// Max node runners
    public let executors = Field<Int>("executors")
    
    /// Node used count
    public let running = Field<Int>("running")

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
    
    public func asDisplay() -> Node.Display {
        return Node.Display(self)
    }
    
    func update(from nodeData: Node.Post) {
        self.name = nodeData.name
        self.host = nodeData.host
        self.port = nodeData.port ?? 22
        self.user = nodeData.user
        self.labels = nodeData.labels?.joined(separator: ",")
        self.auth = nodeData.auth
        self.executors = nodeData.executors
        if let password = nodeData.password {
            self.password = try? Secrets.encrypt(asData: password)
        } else { self.password = nil }
        if let privateKey = nodeData.privateKey {
            self.privateKey = try? Secrets.encrypt(asData: privateKey)
        } else { self.privateKey = nil }
    }
    
}


extension Array where Element == Row<Node> {
    
    public func asDisplay() -> Array<Node.Display> {
        return map { $0.asDisplay() }
    }
    
}
