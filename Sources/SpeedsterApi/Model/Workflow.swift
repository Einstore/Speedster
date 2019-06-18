//
//  Workflow.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import Fluent


/// Single run of a phase in a job
public struct Workflow: Model {
    
    public static let shared = Workflow()
    public static let entity = "workflows"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Name
    public let name = Field<String>("name")
    
    /// Node labels
    public let nodeLabels = Field<String?>("node_labels")
    
    /// Depends on (name)
    public let dependsOn = Field<String?>("depends")
    
    /// Timeout for the whole workflow (seconds, default 3600)
    public let timeout = Field<Int>("timeout")
    
    /// Job will timeout after an interval if no update is received (seconds, default 1800)
    public let timeoutOnInactivity = Field<Int>("timeout_inactivity")
    
    /// Script to start workspace specific environment
    public let environmnetStart = Field<String?>("environmnet_start")
    
    /// Script to stop workspace specific environment
    public let environmnetFinish = Field<String?>("environmnet_ finish")
    
    /// Perform on workflow fail (before always)
    public let fail = Field<SpeedsterCore.Job.Workflow.Phase?>("fail")
    
    /// Perform on workflow success (before always)
    public let success = Field<SpeedsterCore.Job.Workflow.Phase?>("success")
    
    /// Always perform action wherever workflow succeeds of fails (always last to run)
    public let always = Field<SpeedsterCore.Job.Workflow.Phase?>("always")
    
}


extension Workflow {
    
    static func row(from workflow: SpeedsterCore.Job.Workflow, job: Row<Job>) -> Row<Workflow> {
        let row = Workflow.row()
        row.jobId = job.id
        row.name = workflow.name
        row.dependsOn = workflow.dependsOn
        row.timeout = workflow.timeout
        row.timeoutOnInactivity = workflow.timeoutOnInactivity
        return row
    }
    
}
