//
//  Workflow+Core.swift
//  
//
//  Created by Ondrej Rafaj on 13/06/2019.
//

import SpeedsterCore
import Fluent
import GitHubKit


extension Array where Element == Row<Phase> {
    
    func filterAsCore(_ stage: Phase.Stage) -> [SpeedsterCore.Job.Workflow.Phase] {
        return filter({ $0.stage == stage }).map({ $0.asCorePhase() })
    }
    
}

extension Array where Element == Row<Workflow> {
    
    func assembleAsCore(_ phases: [Row<Phase>]) -> [SpeedsterCore.Job.Workflow] {
        return map({ $0.asCoreWorkflow(phases: phases) })
    }
    
}


extension Row where Model == Workflow {
    
    func asCoreWorkflow(phases: [Row<Phase>]) -> SpeedsterCore.Job.Workflow {
        return SpeedsterCore.Job.Workflow(
            name: self.name,
            nodeLabels: self.nodeLabels,
            preBuild: phases.filterAsCore(.pre),
            build: phases.filterAsCore(.build),
            fail: phases.filterAsCore(.fail),
            success: phases.filterAsCore(.success),
            always: phases.filterAsCore(.always),
            timeout: self.timeout,
            timeoutOnInactivity: self.timeoutOnInactivity
        )
    }
    
}


extension Row where Model == Phase {
    
    func asCorePhase() -> SpeedsterCore.Job.Workflow.Phase {
        return SpeedsterCore.Job.Workflow.Phase(
            identifier: self.id?.uuidString,
            name: self.name,
            command: self.command,
            description: self.description
        )
    }
    
}
