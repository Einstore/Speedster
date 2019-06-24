//
//  SpeedsterController.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor
import SpeedsterCore


final class SpeedsterController {
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("example") { req -> Response in
            return try Response.make.yaml(Root.rootAll())
        }
        
        r.get("example", "fail") { req -> Response in
            return try Response.make.yaml(Root.rootDependentFailing())
        }
        
        r.get("example", "small") { req -> Response in
            return try Response.make.yaml(Root.rootSmall())
        }
        
        r.get("example", "success") { req -> Response in
            return try Response.make.yaml(Root.rootDependentSucceeding())
        }
        
        r.get("local") { req -> String in
            let e = Executioner(
                root: Root.rootDependentFailing(),
                node: Node(
                    name: "Localhost",
                    host: "localhost",
                    port: 0,
                    user: nil,
                    password: nil,
                    publicKey: nil,
                    auth: .none
                ),
                on: req.eventLoop
            ) { out, identifier in

            }

            return ":)"
        }
        
        r.webSocket("remote") { (req, webSocket) in
            let e = Executioner(
                root: Root.rootAll(),
                node: Node(
                    name: "Ubuntu Test",
                    host: "157.230.106.39",
                    port: 22,
                    user: "root",
                    password: "exploited",
                    publicKey: nil,
                    auth: .password
                ),
                on: req.eventLoop
            ) { out, identifier in
                webSocket.send("\(out)\n")
            }
            
            webSocket.onError { (webSocket, error) in
                webSocket.send("Error: \(error.localizedDescription)\n")
                close()
            }
            
            func close() {
                do {
                    try webSocket.close().wait()
                } catch {
                    webSocket.send("Error: Unable to close socket - \(error.localizedDescription)\n")
                }
            }
            e.run(finished: {
                close()
            }) { error in
                webSocket.send("Error: \(error.localizedDescription)\n")
                close()
            }
        }
    }
    
}
