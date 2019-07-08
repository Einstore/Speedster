//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import VMWareRunKit
import XCTest
import NIO


final class RunTests: XCTestCase {
    
    var run: VMRun!
    
    override func setUp() {
        super.setUp()
        
        let eventLoop = EmbeddedEventLoop()
        run = try! VMRun(.local, for: .fusion, on: eventLoop)
    }
    
    func testDataComingThrough() {
        let data = try! run.send(command: .list) { text in
            print(text)
        }.wait()
        print(data)
    }
    
    static let allTests = [
        ("testDataComingThrough", testDataComingThrough)
    ]
    
}
