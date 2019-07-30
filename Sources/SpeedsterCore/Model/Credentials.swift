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
        
        public let id: Speedster.DbIdType?
        public let name: String
        public let desc: String?
        public let login: String?
        public let password: Bool
        public let privateKey: Bool
        public let isPrivate: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case desc = "description"
            case login
            case password
            case privateKey = "private_key"
            case isPrivate = "private"
        }
        
        public init(_ row: Row<Credentials>) {
            id = row.id
            name = row.name
            desc = row.desc
            login = row.login
            password = !row.password.isVeryVeryEmpty
            privateKey = !row.privateKey.isVeryVeryEmpty
            isPrivate = row.isPrivate == 1
        }
        
    }
    
    public struct Post: Content {
        
        public let name: String
        public let desc: String?
        public let login: String?
        public let password: String?
        public let privateKey: String?
        public let isPrivate: Bool
        
        enum CodingKeys: String, CodingKey {
            case name
            case desc = "description"
            case login
            case password
            case privateKey = "private_key"
            case isPrivate = "private"
        }
        
    }
    
    public static let shared = Credentials()
    public static let entity = "credentials"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    public let name = Field<String>("name")
    public let desc = Field<String?>("description")
    public let login = Field<String?>("login")
    public let password = Field<Data?>("password", dataType: .data)
    public let privateKey = Field<Data?>("private_key", dataType: .data)
    public let isPrivate = Field<Int>("private")
    
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
        row.isPrivate = post.isPrivate ? 1 : 0
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
    
}


