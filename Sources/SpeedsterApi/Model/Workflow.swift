//
//  Workflow.swift
//  
//
//  Created by Ondrej Rafaj on 12/06/2019.
//

import Fluent
import Vapor


/// Single run of a phase in a job
public struct Workflow: Model {
    
    public static let shared = Workflow()
    public static let entity = "workflows"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Name
    public let name = Field<String>("name")
    
    /// Depends on (name)
    public let dependsOn = Field<String?>("depends")
    
    /// Timeout for the whole workflow (seconds, default 3600)
    public let timeout = Field<Int>("timeout")
    
    /// Job will timeout after an interval if no update is received (seconds, default 1800)
    public let timeoutOnInactivity = Field<Int>("timeout_inactivity")
    
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
