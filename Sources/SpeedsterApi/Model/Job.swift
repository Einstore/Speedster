//
//  Job.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import Fluent


public struct Job: Model {
    
    public static let shared = Job()
    public static let entity = "jobs"
    
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
    public let environment = Field<SpeedsterCore.Job.Env?>("environment")
    
    /// Perform on workflow fail (before always)
    public let fail = Field<[SpeedsterCore.Job.Workflow.Phase]?>("fail")
    
    /// Perform on workflow success (before always)
    public let success = Field<[SpeedsterCore.Job.Workflow.Phase]?>("success")
    
    /// Always perform action wherever workflow succeeds of fails (always last to run)
    public let always = Field<[SpeedsterCore.Job.Workflow.Phase]?>("always")
    
}


extension Job {
    
    static func row(from workflow: SpeedsterCore.Job.Workflow, job: Row<Root>) -> Row<Job> {
        let row = Job.row()
        row.jobId = job.id
        row.name = workflow.name
        row.nodeLabels = workflow.nodeLabels
        row.dependsOn = workflow.dependsOn
        row.timeout = workflow.timeout
        row.timeoutOnInactivity = workflow.timeoutOnInactivity
        row.environment = workflow.environment
        row.fail = workflow.fail
        row.success = workflow.success
        row.always = workflow.always
        return row
    }
    
}
