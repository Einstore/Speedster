//
//  SecretsTests.swift
//  
//
//  Created by Ondrej Rafaj on 25/06/2019.
//

import SpeedsterCore
import XCTest
import CryptoKit


final class SecretsTests: XCTestCase {
    
    func testBase64EncodingDecoding() throws {
        let data = try Data(URandom().generateData(count: 128))
        let base64 = data.base64EncodedData()
        let result = Data(base64Encoded: base64)
        XCTAssertEqual(result, data, "Result don't match")
    }
    
    func testBase64StringEncodingDecoding() throws {
        let data = try Data(URandom().generateData(count: 128))
        let base64 = data.base64EncodedString()
        let result = base64.data(using: .utf8)
        XCTAssertEqual(result, data, "Result don't match")
    }
    
    func testEncryptionDecryption() throws {
        let string = "hello"
        let secret = try Secrets.encrypt(string)
        let result = try Secrets.decrypt(secret)
        XCTAssertEqual(result, string, "Result don't match")
    }
    
    func testDataEncryptionDecryption() throws {
        let string = "hello"
        let secret = try Secrets.encrypt(asData: string)
        let result = try Secrets.decrypt(secret)
        XCTAssertEqual(result, string, "Result don't match")
    }
    
    func testBase64EncryptionDecryption() throws {
        let string = "hello"
        let secret = try Secrets.encrypt(asBase64: string)
        let result = try? Secrets.decrypt(fromBase64: secret)
        XCTAssertEqual(result, string, "Result don't match")
    }
    
    static let allTests = [
        ("testBase64EncodingDecoding", testBase64EncodingDecoding),
        ("testBase64StringEncodingDecoding", testBase64StringEncodingDecoding),
        ("testEncryptionDecryption", testEncryptionDecryption),
        ("testDataEncryptionDecryption", testDataEncryptionDecryption),
        ("testBase64EncryptionDecryption", testBase64EncryptionDecryption)
    ]
    
}

