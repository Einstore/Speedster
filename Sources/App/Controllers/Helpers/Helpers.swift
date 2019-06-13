//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import SpeedsterCore


extension Job.Workflow.Phase {
    
    static func phaseCount(_ num: Int = 10) -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
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
    
    static func phasePwd() -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
            name: "Phase PWD",
            command: "pwd",
            description: "Phase PWD description"
        )
    }
    
    static func phaseLs() -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
            name: "Phase ls -a",
            command: "ls -a",
            description: "Phase ls -a description"
        )
    }
    
    static func phaseAptGet() -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
            name: "Phase apt-get",
            command: "apt-get update",
            description: "Phase apt-get update description"
        )
    }
    
    static func phaseEcho(_ message: String = "Speedster message") -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
            name: "Phase echo",
            command: "echo '\(message)'",
            description: "Phase echo \(message) description"
        )
    }
    
    static func phaseCustom(_ command: String) -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
            name: "Phase \(command)",
            command: command,
            description: "Phase \(command) description"
        )
    }
    
    static func phaseFail() -> Job.Workflow.Phase {
        return Job.Workflow.Phase(
            name: "Phase FAIL",
            command: "format C:/",
            description: "Phase FAIL description"
        )
    }

}


extension Job.Workflow {
    
    static func workflowTimeout(dependsOn: String? = nil) -> Job.Workflow {
        return Job.Workflow(
            name: "Timeout workflow",
            dependsOn: dependsOn,
            timeout: 2,
            timeoutOnInactivity: 1,
            preBuild: [
                Phase.phaseEcho("Starting count to 10")
            ],
            build: [
                Phase.phaseCount(4)
            ],
            postBuild: []
        )
    }
    
    static func workflowFailPreBuild(dependsOn: String? = nil) -> Job.Workflow {
        return Job.Workflow(
            name: "Fail pre-build workflow",
            dependsOn: dependsOn,
            timeout: 2,
            timeoutOnInactivity: 1,
            preBuild: [
                Phase.phaseEcho("Starting fail"),
                Phase.phaseFail()
            ],
            build: [
                Phase.phaseEcho("Should have failed in pre-build")
            ],
            postBuild: [
                Phase.phaseEcho("Should have failed in pre-build")
            ]
        )
    }
    
    static func workflowFailBuild(dependsOn: String? = nil) -> Job.Workflow {
        return Job.Workflow(
            name: "Fail build workflow",
            dependsOn: dependsOn,
            timeout: 2,
            timeoutOnInactivity: 1,
            preBuild: [
                Phase.phaseEcho("Starting fail")
            ],
            build: [
                Phase.phaseEcho("Starting build"),
                Phase.phaseFail()
            ],
            postBuild: [
                Phase.phaseEcho("Should have failed in build")
            ]
        )
    }
    
    static func workflowFailPostBuild(dependsOn: String? = nil) -> Job.Workflow {
        return Job.Workflow(
            name: "Fail post-build workflow",
            dependsOn: dependsOn,
            timeout: 2,
            timeoutOnInactivity: 1,
            preBuild: [
                Phase.phaseEcho("Starting fail"),
            ],
            build: [
                Phase.phaseEcho("Starting build")
            ],
            postBuild: [
                Phase.phaseEcho("Starting post-build"),
                Phase.phaseFail(),
                Phase.phaseEcho("Should have failed step before this one!!!")
            ]
        )
    }
    
    static func workflowFull(_ customName: String = "Full", dependsOn: String? = nil) -> Job.Workflow {
        return Job.Workflow(
            name: "Timeout workflow",
            dependsOn: dependsOn,
            timeout: 3600,
            timeoutOnInactivity: 1800,
            preBuild: [
                Phase.phaseEcho("Starting \(customName) workflow"),
                Phase.phaseAptGet()
            ],
            build: [
                Phase.phaseCount(4),
                Phase.phasePwd(),
                Phase.phaseLs()
            ],
            postBuild: [
                Phase.phaseEcho("Finishing \(customName) workflow"),
            ]
        )
    }
    
}


extension Job {
    
    static func jobDependentFailing() -> Job {
        let w1 = Workflow.workflowFull("Step 1")
        let w2 = Workflow.workflowFull("Step 2", dependsOn: w1.name)
        let w3 = Workflow.workflowFailBuild(dependsOn: w2.name)
        let w4 = Workflow.workflowFull("Step 4", dependsOn: w3.name)
        
        return Job(
            name: "Dependant job failing",
            repoUrl: "https://github.com/vapor/postgres-nio/",
            workflows: [w1, w2, w3, w4]
        )
    }
    
    static func jobDependentSucceeding() -> Job {
        let w1 = Workflow.workflowFull("Step 1")
        let w2 = Workflow.workflowFull("Step 2", dependsOn: w1.name)
        let w3 = Workflow.workflowFull("Step 3", dependsOn: w2.name)
        let w4 = Workflow.workflowFull("Step 4", dependsOn: w3.name)
        
        return Job(
            name: "Dependant job succeeding",
            repoUrl: "https://github.com/vapor/postgres-nio/",
            workflows: [w1, w2, w3, w4]
        )
    }
    
    static func jobAll() -> Job {
        let w1 = Workflow.workflowFailBuild()
        let w2 = Workflow.workflowFailPreBuild()
        let w3 = Workflow.workflowFailPostBuild()
        let w4 = Workflow.workflowFull()
        let w5 = Workflow.workflowTimeout()
        
        return Job(
            name: "All workflows",
            repoUrl: "https://github.com/vapor/postgres-nio/",
            workflows: [w1, w2, w3, w4, w5]
        )
    }
    
}
