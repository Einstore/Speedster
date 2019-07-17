//
//  NodesManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent
import CommandKit
import WebErrorKit


class NodesManager {
    
    enum Error: String, WebError {
        case errorExitCode
    }
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    // MARK: Node distribution
    
    func next(_ labels: [String]? = nil) -> EventLoopFuture<Row<Node>?> {
        let q = Node.query(on: db)
            .filter(\Node.running < 2)
        if let labels = labels {
            for label: String in labels {
                q.filter(\Node.labels == label)
            }
        }
        return q.first().flatMap { node in
            guard let node = node else {
                return self.db.eventLoop.makeSucceededFuture(nil)
            }
            node.running += 1
            return node.update(on: self.db).map { _ in
                return node
            }
        }
    }
    
    // MARK: Node helpers
    
    var software: [String] {
        return [
            "curl",
            "docker",
            "git",
            "top",
            "vmrun",
            "brew",
            "apt"
        ]
    }
    
    func software(for node: Row<Node>) -> EventLoopFuture<[String: Bool]> {
        do {
            let conn = try node.asShellConnection()
            let shell = try Shell(conn, on: db.eventLoop)
            
            var out: [String: Bool] = [:]
            
            func check(soft: [String]) -> EventLoopFuture<Void> {
                guard let cmd = soft.first else {
                    return db.eventLoop.makeSucceededFuture(Void())
                }
                return shell.cmd.exists(command: cmd).flatMap { res in
                    out[cmd] = res
                    let ns = Array(soft.dropFirst())
                    return check(soft: ns)
                }
            }
            
            return check(soft: software).map { _ in
                return out
            }
        } catch {
            return error.fail(db)
        }
    }
    
    func install(_ command: String, req: Request, webSocket: WebSocket) {
        fatalError()
//        webSocket.send("Starting install")
//        let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
//        Node.find(failing: id, on: self.db).whenSuccess { node in
//            guard let coreNode = try? node.asCore() else {
//                webSocket.send("Invalid node data\n")
//                webSocket.close(code: .unexpectedServerError, promise: nil)
//                return
//            }
//            webSocket.send("Using \(coreNode.name)")
//            coreNode.run(bash: command, on: req.eventLoop, output: { out in
//                print(out)
//                webSocket.send(out)
//            }, finished: {
//                webSocket.send("Success\n")
//                webSocket.close(code: .normalClosure, promise: nil)
//            }, failed: { error in
//                webSocket.send("Error: \(error)\n")
//                webSocket.send("Failure\n")
//                webSocket.close(code: .unexpectedServerError, promise: nil)
//            })
//        }
    }
    
    func install(_ command: String, req: Request) -> EventLoopFuture<String> {
        fatalError()
//        let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
//        return Node.find(failing: id, on: self.db).flatMap { node in
//            guard let coreNode = try? node.asCore() else {
//                return req.eventLoop.makeFailedFuture(GenericError.decodingError)
//            }
//            let promise = req.eventLoop.makePromise(of: String.self)
//            var output = ""
//            coreNode.run(bash: command, on: req.eventLoop, output: { out in
//                print(out)
//                output += out
//            }, finished: {
//                req.eventLoop.execute {
//                    promise.succeed(output)
//                }
//            }, failed: { error in
//                req.eventLoop.execute {
//                    promise.fail(error)
//                }
//            })
//            return promise.futureResult
//        }
    }
    
}
