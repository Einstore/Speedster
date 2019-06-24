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
            nodeLabels: "linux,mac",
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
            nodeLabels: "linux,mac",
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
            nodeLabels: "linux,mac",
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
            nodeLabels: "linux,mac",
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
            nodeLabels: "linux",
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
    
    static func jobSmall(_ customName: String = "Small", dependsOn: String? = nil) -> Root.Job {
        return Root.Job(
            name: "\(customName) job",
            nodeLabels: "linux",
            dependsOn: dependsOn,
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
    
    static func pipelines() -> [Root.Pipeline] {
        return [
            Root.Pipeline(
                triggers: [
                    Trigger(name: "master", action: .commit, jobs: ["Step 1"]),
                    Trigger(name: "development", action: .message("test please"), jobs: ["Step 1"]),
                    Trigger(
                        name: "master",
                        action: .message("build please"),
                        jobs: ["Step 1"]
                    )
                ],
                jobs: [
                    "Step 1"
                ]
            )
        ]
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
            gitHub: Root.GitHub(
                cloneGit: "git@github.com:vapor/postgres-nio.git"
            ),
            jobs: [w1, w2, w3, w4],
            pipelines: Pipeline.pipelines()
        )
    }
    
    static func rootSmall() -> Root {
        let w1 = Job.jobSmall()
        
        return Root(
            name: "Small root",
            gitHub: Root.GitHub(
                cloneGit: "git@github.com:vapor/postgres-nio.git"
            ),
            jobs: [w1],
            environment: Root.Env(
                start: "github:rafiki270/docker-environment:master",
                finish: "github:rafiki270/docker-environment:master"
            ),
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
            pipelines: Pipeline.pipelines()
        )
    }
    
    static func rootDependentSucceeding() -> Root {
        let w1 = Job.jobFull("Step 1")
        let w2 = Job.jobFull("Step 2", dependsOn: w1.name)
        let w3 = Job.jobFull("Step 3", dependsOn: w2.name)
        let w4 = Job.jobFull("Step 4", dependsOn: w3.name)
        
        return Root(
            name: "Dependant job succeeding",
            gitHub: Root.GitHub(
                cloneGit: "git@github.com:vapor/postgres-nio.git"
            ),
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
            nodeLabels: "linux",
            gitHub: Root.GitHub(
                cloneGit: "git@github.com:vapor/postgres-nio.git"
            ),
            jobs: [w1, w2, w3, w4, w5],
            pipelines: Pipeline.pipelines()
        )
    }
    
}
