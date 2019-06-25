//
//  NodesManager.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent


class NodesManager {
    
    enum Error: Swift.Error {
        case errorExitCode
    }
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func next(_ labels: [String]? = nil) -> EventLoopFuture<Row<Node>?> {
        let q = Node.query(on: db)
            .filter(\Node.running == 0)
        if let labels = labels {
            q.filter(\Node.labels, in: labels)
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
    
    func install(_ command: String, req: Request, webSocket: WebSocket) {
        webSocket.send("Starting install")
        let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
        Node.find(failing: id, on: self.db).whenSuccess { node in
            guard let coreNode = try? node.asCore() else {
                webSocket.send("Invalid node data\n")
                webSocket.close(code: .unexpectedServerError, promise: nil)
                return
            }
            webSocket.send("Using \(coreNode.name)")
            coreNode.run(bash: command, on: req.eventLoop, output: { out in
                print(out)
                webSocket.send(out)
            }, finished: {
                webSocket.send("Success\n")
                webSocket.close(code: .normalClosure, promise: nil)
            }, failed: { error in
                webSocket.send("Error: \(error)\n")
                webSocket.send("Failure\n")
                webSocket.close(code: .unexpectedServerError, promise: nil)
            })
        }
    }
    
    func install(_ command: String, req: Request) -> EventLoopFuture<String> {
        let id = req.parameters.get("node_id", as: Speedster.DbIdType.self)
        return Node.find(failing: id, on: self.db).flatMap { node in
            guard let coreNode = try? node.asCore() else {
                return req.eventLoop.makeFailedFuture(GenericError.decodingError)
            }
            let promise = req.eventLoop.makePromise(of: String.self)
            var output = ""
            coreNode.run(bash: command, on: req.eventLoop, output: { out in
                print(out)
                output += out
            }, finished: {
                req.eventLoop.execute {
                    promise.succeed(output)
                }
            }, failed: { error in
                req.eventLoop.execute {
                    promise.fail(error)
                }
            })
            return promise.futureResult
        }
    }
    
}
