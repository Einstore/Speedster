//
//  Credentials.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent
import SecretsKit


/// Credentials storage
public struct Credentials: Model {
    
    public struct Display: Content {
        
        public var id: Speedster.DbIdType?
        public var name: String
        public var desc: String?
        public var login: String?
        public var password: Bool
        public var privateKey: Bool
        public var publicKey: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case desc
            case login
            case password
            case privateKey = "private_key"
            case publicKey = "public_key"
        }
        
        public init(_ row: Row<Credentials>) {
            id = row.id
            name = row.name
            desc = row.desc
            login = row.login
            password = !row.password.isVeryVeryEmpty
            privateKey = !row.privateKey.isVeryVeryEmpty
            publicKey = !row.publicKey.isVeryVeryEmpty
        }
        
    }
    
    public struct Post: Content {
        
        public var name: String
        public var desc: String?
        public var login: String?
        public var password: String?
        public var privateKey: String?
        public var publicKey: String?
        
        enum CodingKeys: String, CodingKey {
            case name
            case desc
            case login
            case password
            case privateKey = "private_key"
            case publicKey = "public_key"
        }
        
    }
    
    public static let shared = Credentials()
    public static let entity = "credentials"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    public let name = Field<String>("name")
    public let desc = Field<String?>("description")
    public let login = Field<String?>("login")
    public let password = Field<Data?>("password")
    public let privateKey = Field<Data?>("private_key")
    public let publicKey = Field<Data?>("public_key")
    
    public static func row(from post: Post) -> Row<Credentials> {
        let row = self.row()
        row.name = post.name
        row.desc = post.desc
        row.login = post.login
        if let value = post.password {
            row.password = try? Secrets.encrypt(asData: value)
        } else { row.password = nil }
        if let value = post.privateKey {
            row.privateKey = try? Secrets.encrypt(asData: value)
        } else { row.privateKey = nil }
        if let value = post.publicKey {
            row.publicKey = try? Secrets.encrypt(asData: value)
        } else { row.publicKey = nil }
        return row
    }

}


extension Row where Model == Credentials {
    
    public func asDisplay() -> Credentials.Display {
        return Credentials.Display(self)
    }
    
    public var passwordDecrypted: String? {
        guard let data = self.password else {
            return nil
        }
        return try? Secrets.decrypt(string: data)
    }
    
    public var privateKeyDecrypted: String? {
        guard let data = self.privateKey else {
            return nil
        }
        return try? Secrets.decrypt(string: data)
    }
    
    public var publicKeyDecrypted: String? {
        guard let data = self.publicKey else {
            return nil
        }
        return try? Secrets.decrypt(string: data)
    }
    
}


