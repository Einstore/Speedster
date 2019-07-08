//
//  EncodingTests.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import SpeedsterCore
import XCTest
import CryptoKit
import Yams


final class EncodingTests: XCTestCase {
    
    func testRootEncoding() {
        let all = Root.rootAll()
        let encoded = try! YAMLEncoder().encode(all)
        _ = try! Root.decode(from: encoded)
        print("We got here so probs ok :)")
    }
    
    static let allTests = [
        ("testRootEncoding", testRootEncoding)
    ]

}
