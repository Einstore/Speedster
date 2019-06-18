//
//  Secrets.swift
//  
//
//  Created by Ondrej Rafaj on 15/06/2019.
//

import Vapor
import CryptoKit


public class Secrets {
    
    public enum Error: Swift.Error {
        case invalidBase64Data
    }
    
    static var secret: [UInt8] {
        let refMessage = "Refer to https://github.com/Einstore/Speedster/wiki/Generating-a-secret-key-to-secure-stored-credentials for details."
        guard let secret = Environment.get("SECRET") else {
            if (try? Environment.detect()) == Environment.development {
                return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]
            }
            fatalError("Environmental variable SECRET has to be set! \(refMessage)")
        }
        
        guard let baseData = Data(base64Encoded: secret)?.dropFirst(10), baseData.count == 32 else {
            fatalError("Invalid SECRET. \(refMessage)")
        }
        return Array(baseData) 
    }
    
    public static func encrypt(_ string: String) throws -> [UInt8] {
        let nonce = try URandom().generateData(count: 12)
        let (ciphertext, tag) = try AES256GCM.encrypt(.string(string), key: .bytes(secret), iv: .bytes(nonce))
        
        var out: [UInt8] = nonce
        out.append(contentsOf: ciphertext.bytes())
        out.append(contentsOf: tag.bytes())
        return out
    }
    
    public static func encrypt(asBase64 string: String) throws -> String {
        let encrypted = try encrypt(string)
        let base64 = Data(encrypted).base64EncodedString()
        return base64
    }
    
    public static func decrypt(_ data: [UInt8]) throws -> String? {
        let nonce = Array(data[0...11])
        let ciphertext = Array(data[12...(data.count - 17)])
        let tag = Array(data[(data.endIndex - 16)...(data.count - 1)])
        
        let out = try AES256GCM.decrypt(.bytes(ciphertext), key: .bytes(secret), iv: .bytes(nonce), tag: .bytes(tag))
        return String(bytes: out.bytes(), encoding: .utf8)
    }
    
    public static func decrypt(fromBase64 base64: String) throws -> String? {
        guard let data = base64.data(using: .utf8) else {
            throw Error.invalidBase64Data
        }
        let bytes = Array(data)
        return try decrypt(bytes)
    }
    
}
