//
//  Node.swift
//  
//
//  Created by Ondrej Rafaj on 09/06/2019.
//

import Vapor


public struct Node: Content {
    
    public enum Auth: String, Codable {
        case none = "na"
        case me = "me"
        case password = "ps"
        case privateKey = "pk"
    }
    
    /// Node name
    public let name: String
    
    /// Host (no protocol, ex. example.com)
    public let host: String
    
    /// Port to connect to
    public let port: Int
    
    /// Port to connect to
    public let user: String?
    
    /// Login password (if auth is 2) or an optional passphrase (if auth is 3)
    public let password: String?
    
    /// Public key certificate
    public let publicKey: String?
    
    /// Authentication
    public let auth: Auth
    
    /// Host (no protocol, ex. example.com)
    public let dir: String
    
    /// Initializer
    public init(name: String, host: String, port: Int, user: String?, password: String?, publicKey: String?, auth: Auth, dir: String = "~/Speedster") {
        self.name = name
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.publicKey = publicKey
        self.auth = auth
        self.dir = dir
    }
    
}


extension Node {
    
    public func run(bash command: String, on eventLoop: EventLoop, output: ((String) -> ())? = nil) throws -> Int {
        let ex = Executioner(node: self, on: eventLoop, output: { out, id in
            output?(out)
        })
        return try ex.run(bash: command)
    }
    
}
