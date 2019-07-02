//
//  Credential.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent


/// Credentials storage
public struct Credential: Model {
    
    public static let shared = Credential()
    public static let entity = "credentials"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    public let username = Field<String>("username")
    public let password = Field<String>("password")
    public let privateKey = Field<String>("private_key")
    public let publicKey = Field<String>("public_key")

}

