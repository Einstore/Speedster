//
//  Tests.swift
//  
//
//  Created by Ondrej Rafaj on 07/07/2019.
//

@testable import RefRepoKit
import XCTest
import NIO
import CommandKit


/*
 Warning: The below tests rely on an external service which in a testing environment should be a NO-GO but for the convenience and as this package needs github to work we have decided to test the actual real functionality without mocks ond stubs !!!!!!!!
 Also! Tests should not be run in parallel
 */


final class RefRepoTests: XCTestCase {
    
    let repoSSH = "git@github.com:Einstore/Einstore.git"
    let repoHTTPS = "https://github.com/Einstore/ShellKit.git"
    
    var ref: RefRepo!
    var shell: Shell!
    
    var output: String = ""
    
    override func setUp() {
        super.setUp()
        
        let eventLoop = EmbeddedEventLoop()
        
        ref = try! RefRepo(
            .local,
            temp: "/tmp/test-refrepo/",
            on: eventLoop)
        { text in
            print(text)
            self.output += text
        }
        
        shell = try! Shell(.local(dir: "/tmp"), on: eventLoop)
        shell.outputCommands = false
        
        _ = try! shell.cmd.rm(path: ref.tmp(for: repoSSH), flags: "-rf").wait()
        _ = try! shell.cmd.rm(path: ref.tmp(for: repoHTTPS), flags: "-rf").wait()
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! ref.clean(for: "test-stuff").wait()
    }
    
    func testShell() {
        var count = 0
        _ = try! shell.run(bash: "pwd") { s in
            XCTAssertEqual(s.trimmingCharacters(in: .newlines), "/tmp")
            count += 1
        }.wait()
        XCTAssertEqual(count, 1)
    }
    
    func testLongShell() {
        var count = 0
        let command = """
        for ((i=1;i<=3;i++));
            do
                echo $i
                echo "\n"
                sleep 1
        done
        """
        _ = try! shell.run(bash: command) { s in
            count += 1
            XCTAssertEqual(s.trimmingCharacters(in: .newlines), String(count))
        }.wait()
        XCTAssertEqual(count, 3)
    }
    
    func testCloneSSH() {
        ref.sshKeys.append("id_rsa.0")
        let string = try! ref.clone(repo: repoSSH, checkout: "master", target: "/tmp/test-refrepo/clones/test-stuff", workspace: "/tmp/test-refrepo/clones/").wait()
        
        let content = try! FileManager.default.contentsOfDirectory(atPath: string)
        XCTAssertTrue(content.count > 3)
        XCTAssertTrue(content.contains(".git"))
        
        XCTAssertTrue(output.contains(repoSSH), "Text not present in: \(output)")
        
        XCTAssertEqual(string, "/tmp/test-refrepo/clones/test-stuff")
    }
    
    func testCloneHTTPS() {
        let string = try! ref.clone(repo: repoHTTPS, checkout: "master", target: "/tmp/test-refrepo/clones/test-stuff", workspace: "/tmp/test-refrepo/clones/").wait()
        
        let content = try! FileManager.default.contentsOfDirectory(atPath: string)
        XCTAssertTrue(content.count > 3)
        XCTAssertTrue(content.contains(".git"))
        
        XCTAssertTrue(output.contains(repoHTTPS), "Text not present in: \(output)")
        
        XCTAssertEqual(string, "/tmp/test-refrepo/clones/test-stuff")
    }
    
    func testFetchSSH() {
        ref.sshKeys.append("id_rsa.0")
        _ = try! shell.run(bash: "git clone \(repoSSH) \(ref.tmp(for: repoSSH))").wait()
        
        let string = try! ref.clone(repo: repoSSH, checkout: "master", target: "/tmp/test-refrepo/clones/test-stuff", workspace: "/tmp/test-refrepo/clones/").wait()
        
        let content = try! FileManager.default.contentsOfDirectory(atPath: string)
        XCTAssertTrue(content.count > 3)
        XCTAssertTrue(content.contains(".git"))
        
        XCTAssertTrue(output.contains("Your branch is up to date with 'origin/master'"), "Text not present in: \(output)")
        
        XCTAssertEqual(string, "/tmp/test-refrepo/clones/test-stuff")
    }
    
    func testFetchHTTPS() {
        _ = try! shell.run(bash: "git clone \(repoHTTPS) \(ref.tmp(for: repoSSH))").wait()
        
        let string = try! ref.clone(repo: repoHTTPS, checkout: "master", target: "/tmp/test-refrepo/clones/test-stuff", workspace: "/tmp/test-refrepo/clones/").wait()
        
        let content = try! FileManager.default.contentsOfDirectory(atPath: string)
        XCTAssertTrue(content.count > 3)
        XCTAssertTrue(content.contains(".git"))
        
        XCTAssertTrue(output.contains("Your branch is up to date with 'origin/master'"), "Text not present in: \(output)")
        
        XCTAssertEqual(string, "/tmp/test-refrepo/clones/test-stuff")
    }
    
    static let allTests = [
        ("testShell", testShell),
        ("testLongShell", testLongShell),
        ("testCloneSSH", testCloneSSH),
        ("testCloneHTTPS", testCloneHTTPS),
        ("testFetchSSH", testFetchSSH),
        ("testFetchHTTPS", testFetchHTTPS)
    ]
    
}

