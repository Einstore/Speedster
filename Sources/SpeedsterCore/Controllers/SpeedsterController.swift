//
//  SpeedsterController.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Foundation
import Vapor


final class SpeedsterController: Controller {
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("local") { req -> String in
            let e = Executioner(
                job: Job(
                    name: "Test job",
                    timeout: 10,
                    timeoutOnInactivity: 5,
                    preBuild: [
                        Job.Phase(
                            name: "a) Phase 1",
                            command: "pwd",
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
            )
            return try e.run()
        }
        
        r.get("remote") { req -> String in
            let e = Executioner(
                job: Job(
                    name: "Remote test job",
                    timeout: 10,
                    timeoutOnInactivity: 5,
                    preBuild: [
                        Job.Phase(
                            name: "a) Phase 1",
                            command: "pwd",
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
            )
            return try e.run()
        }
    }
    
}
