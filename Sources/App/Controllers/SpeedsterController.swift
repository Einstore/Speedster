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
        r.get("generate") { req -> Job in
            return Job(
                name: "Test job",
                repoUrl: "https://github.com/Einstore/GithubAPI",
                timeout: 3600,
                timeoutOnInactivity: 1800,
                preBuild: [
                    Job.Phase(
                        name: "a) Phase 1",
                        command: """
for ((i=1;i<=100;i++));
do
    echo $i
    echo "\n"
done
""",
                        description: "Phase 1 description"
                    )
                ],
                build: [
                    Job.Phase(
                        name: "b) Phase 1",
                        command: "pwd",
                        description: "Phase 1 description"
                    ),
                    Job.Phase(
                        name: "b) Phase 2",
                        command: "ls -a",
                        description: "Phase 2 description"
                    )
                ],
                postBuild: [
                    Job.Phase(
                        name: "c) Phase 1",
                        command: "pwd",
                        description: "Phase 1 description"
                    )
                ]
            )
        }
        
        r.get("local") { req -> String in
            let e = Executioner(
                job: Job(
                    name: "Test job",
                    timeout: 10,
                    timeoutOnInactivity: 5,
                    preBuild: [
                        Job.Phase(
                            name: "a) Phase 1",
                            command: """
for ((i=1;i<=100;i++));
do
    echo $i
    echo "\n"
done
""",
                            description: "Phase 1 description"
                        )
                    ],
                    build: [
                        Job.Phase(
                            name: "b) Phase 1",
                            command: "pwd",
                            description: "Phase 1 description"
                        ),
                        Job.Phase(
                            name: "b) Phase 2",
                            command: "ls -a",
                            description: "Phase 2 description"
                        )
                    ],
                    postBuild: [
                        Job.Phase(
                            name: "c) Phase 1",
                            command: "pwd",
                            description: "Phase 1 description"
                        )
                    ]
                ),
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
            ) { out in
                
            }
            
            return ":)"
        }
        
        r.webSocket("remote") { (req, webSocket) in
            let e = Executioner(
                job: Job(
                    name: "Remote test job",
                    timeout: 10,
                    timeoutOnInactivity: 5,
                    preBuild: [
                        Job.Phase(
                            name: "a) Phase 1",
                            command: """
apt-get update
for ((i=1;i<=10;i++));
do
    echo $i
    echo "\n"
    sleep 1
done
""",
                            description: "Phase 1 description"
                        )
                    ],
                    build: [
                        Job.Phase(
                            name: "b) Phase 1",
                            command: "pwd",
                            description: "Phase 1 description"
                        ),
                        Job.Phase(
                            name: "b) Phase 2",
                            command: """
                                pwd
                                ls ~/ -a
                                pwd
                                """,
                            description: "Phase 2 description"
                        )
                    ],
                    postBuild: [
                        Job.Phase(
                            name: "c) Phase 1",
                            command: "pwd",
                            description: "Phase 1 description"
                        )
                    ]
                ),
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
            ) { out in
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
