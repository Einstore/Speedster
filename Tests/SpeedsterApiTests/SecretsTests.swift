//
//  SecretsTests.swift
//  
//
//  Created by Ondrej Rafaj on 25/06/2019.
//

import SpeedsterApi
import XCTest


final class SecretsTests: XCTestCase {
    
    func testEncryptionDecryption() throws {
        let string = "hello"
        let secret = try! Secrets.encrypt(string)
        let result = try! Secrets.decrypt(secret)
        XCTAssertEqual(result, string, "Result don't match")
    }
    
    func testBase64EncryptionDecryption() throws {
        let string = "hello"
        let secret = try! Secrets.encrypt(asBase64: string)
        let result = try! Secrets.decrypt(fromBase64: secret)
        XCTAssertEqual(result, string, "Result don't match")
    }
    
    static let allTests = [
        ("testEncryptionDecryption", testEncryptionDecryption),
        ("testBase64EncryptionDecryption", testBase64EncryptionDecryption)
    ]
    
}

