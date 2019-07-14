//
//  Helpers.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import SpeedsterCore


extension Root.Job.Phase {
    
    static func phaseCount(_ num: Int = 10) -> Root.Job.Phase {
        return Root.Job.Phase(
            name: "Count phase",
            command: """
                for ((i=1;i<=\(num);i++));
                do
                    echo $i
                    echo "\n"
                    sleep 1
                done
                """,
            description: "Phase count description"
        )
    }
    
    static func phasePwd() -> Root.Job.Phase {
        return Root.Job.Phase(
            name: "Phase PWD",
            command: "pwd",
            description: "Phase PWD description"
        )
    }
    
    static func phaseLs() -> Root.Job.Phase {
        return Root.Job.Phase(
            name: "Phase ls -a",
            command: "ls -a",
            description: "Phase ls -a description"
        )
    }
    
    static func phaseAptGet() -> Root.Job.Phase {
        return Root.Job.Phase(
            name: "Phase apt-get",
            command: "apt-get update",
            description: "Phase apt-get update description"
        )
    }
    
    static func phaseEcho(_ message: String = "Speedster message") -> Root.Job.Phase {
        return Root.Job.Phase(
            command: "echo '\(message)'"
        )
    }
    
    static func phaseCustom(_ command: String) -> Root.Job.Phase {
        return Root.Job.Phase(
            name: "Phase \(command)",
            command: command,
            description: "Phase \(command) description"
        )
    }
    
    static func phaseFail() -> Root.Job.Phase {
        return Root.Job.Phase(
            name: "Phase FAIL",
            command: "format C:/",
            description: "Phase FAIL description"
        )
    }

}


extension Root.Job {
    
    static func jobTimeout(dependsOn: String? = nil) -> Root.Job {
        return Root.Job(
            name: "Timeout workflow",
            nodeLabels: ["linux", "mac"],
            dependsOn: dependsOn,
            preBuild: [
                Phase.phaseEcho("Starting count to 10")
            ],
            build: [
                Phase.phaseCount(4)
            ],
            fail: [Phase.phaseEcho("I have failed you master! :(")],
            success: [Phase.phaseEcho("Yay!")],
            always: [Phase.phaseEcho("I am done!")],
            timeout: 2,
            timeoutOnInactivity: 1
        )
    }
    
    static func jobFailPreBuild(dependsOn: String? = nil) -> Root.Job {
        return Root.Job(
            name: "Fail pre-build workflow",
            nodeLabels: ["linux", "mac"],
            dependsOn: dependsOn,
            preBuild: [
                Phase.phaseEcho("Starting fail"),
                Phase.phaseFail()
            ],
            build: [
                Phase.phaseEcho("Should have failed in pre-build")
            ],
            fail: [Phase.phaseEcho("I have failed you master! :(")],
            success: [Phase.phaseEcho("Yay!")],
            always: [Phase.phaseEcho("I am done!")],
            timeout: 2,
            timeoutOnInactivity: 1
        )
    }
    
    static func jobFailBuild(dependsOn: String? = nil) -> Root.Job {
        return Root.Job(
            name: "Fail build workflow",
            nodeLabels: ["linux", "mac"],
            dependsOn: dependsOn,
            preBuild: [
                Phase.phaseEcho("Starting fail")
            ],
            build: [
                Phase.phaseEcho("Starting build"),
                Phase.phaseFail()
            ],
            fail: [Phase.phaseEcho("I have failed you master! :(")],
            success: [Phase.phaseEcho("Yay!")],
            always: [Phase.phaseEcho("I am done!")],
            timeout: 2,
            timeoutOnInactivity: 1
        )
    }
    
    static func jobFailPostBuild(dependsOn: String? = nil) -> Root.Job {
        return Root.Job(
            name: "Fail post-build workflow",
            nodeLabels: ["linux", "mac"],
            dependsOn: dependsOn,
            preBuild: [
                Phase.phaseEcho("Starting fail"),
            ],
            build: [
                Phase.phaseEcho("Starting build")
            ],
            fail: [Phase.phaseEcho("I have failed you master! :(")],
            success: [Phase.phaseEcho("Yay!")],
            always: [Phase.phaseEcho("I am done!")],
            timeout: 2,
            timeoutOnInactivity: 1
        )
    }
    
    static func jobFull(_ customName: String = "Full", dependsOn: String? = nil) -> Root.Job {
        return Root.Job(
            name: "\(customName) workflow",
            nodeLabels: ["linux", "mac"],
            dependsOn: dependsOn,
            preBuild: [
                Phase.phaseEcho("Starting \(customName) workflow"),
                Phase.phaseAptGet()
            ],
            build: [
                Phase.phaseCount(4),
                Phase.phasePwd(),
                Phase.phaseLs()
            ],
            fail: [Phase.phaseEcho("I have failed you master! :(")],
            success: [Phase.phaseEcho("Yay!")],
            always: [Phase.phaseEcho("I am done!")],
            timeout: 3600,
            timeoutOnInactivity: 1800
        )
    }
    
    static func jobSmall(_ customName: String = "Small", dependsOn: String? = nil, env: Bool = false) -> Root.Job {
        return Root.Job(
            name: "\(customName) job",
            nodeLabels: ["linux"],
            dependsOn: dependsOn,
            environment: (env ? Root.Env.basic() : nil),
            preBuild: [
                Phase.phaseEcho("Starting \(customName) workflow"),
            ],
            build: [
                Phase.phaseLs()
            ],
            fail: [Phase.phaseEcho("I have failed you master! :(")],
            success: [Phase.phaseEcho("Yay!")],
            always: [Phase.phaseEcho("I am done!")],
            timeout: 10,
            timeoutOnInactivity: 5
        )
    }
    
}

extension Root.Pipeline {
    
    static func pipelines(jobs: [String] = ["Step 1", "Step 2", "Step 3"]) -> [Root.Pipeline] {
        return [
            Root.Pipeline(
                name: "Pipeline for \(jobs.joined(separator: ", "))",
                triggers: [
                    Trigger(ref: "master", action: .commit),
                    Trigger(ref: "development", action: .message("test please")),
                    Trigger(
                        ref: "master",
                        action: .message("build please")
                    )
                ],
                jobs: jobs
            )
        ]
    }
    
}

extension Root.Env {
    
    static func basic() -> Root.Env {
        return Root.Env(
            image: .VMWare(name: "/Users/pro/Virtual Machines.localized/Windows 10 x64.vmwarevm/Windows 10 x64.vmx"),
            memory: "4Gib",
            storage: "10Gib",
            variables: [
                "VAR1": "value 1",
                "VAR2": "value 2"
            ]
        )
    }
    
}

extension Root {
    
    static func rootDependentFailing() -> Root {
        let w1 = Job.jobFull("Step 1")
        let w2 = Job.jobFull("Step 2", dependsOn: w1.name)
        let w3 = Job.jobFailBuild(dependsOn: w2.name)
        let w4 = Job.jobFull("Step 4", dependsOn: w3.name)
        
        return Root(
            name: "Dependant root failing",
            jobs: [w1, w2, w3, w4],
            pipelines: Pipeline.pipelines()
        )
    }
    
    static func rootSmall() -> Root {
        let w1 = Job.jobSmall()
        let w2 = Job.jobSmall("Linux", dependsOn: w1.name, env: true)
        
        return Root(
            name: "Small root",
            source: Root.Git(
                referenceRepo: Root.Git.Reference(
                    origin: "git@github.com:Einstore/Einstore.git",
                    rsa: [
                        "github.com": "nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8"
                    ],
                    ssh: [
                        "github.com",
                        "ford.github.com"
                    ]
                ),
                apiDownload: true
            ),
            jobs: [w1, w2],
            environment: Root.Env.basic(),
            dockerDependendencies: [
                Dependency(
                    image: "postgres:11",
                    networkName: "psql",
                    cmd: nil,
                    entrypoint: nil,
                    variables: [
                        "POSTGRES_USER": "speedster",
                        "POSTGRES_DB": "speedster",
                        "POSTGRES_PASSWORD": "aaaaaa"
                    ]
                )
            ],
            pipelines: Pipeline.pipelines(jobs: [w1.name, w2.name])
        )
    }
    
    static func rootDependentSucceeding() -> Root {
        let w1 = Job.jobFull("Step 1")
        let w2 = Job.jobFull("Step 2", dependsOn: w1.name)
        let w3 = Job.jobFull("Step 3", dependsOn: w2.name)
        let w4 = Job.jobFull("Step 4", dependsOn: w3.name)
        
        return Root(
            name: "Dependant job succeeding",
            jobs: [w1, w2, w3, w4],
            pipelines: Pipeline.pipelines()
        )
    }
    
    static func rootAll() -> Root {
        let w1 = Job.jobFailBuild()
        let w2 = Job.jobFailPreBuild()
        let w3 = Job.jobFailPostBuild()
        let w4 = Job.jobFull()
        let w5 = Job.jobTimeout()
        
        return Root(
            name: "All workflows",
            nodeLabels: ["linux"],
            jobs: [w1, w2, w3, w4, w5],
            pipelines: Pipeline.pipelines()
        )
    }
    
}
