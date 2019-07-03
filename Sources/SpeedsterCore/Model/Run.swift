//
//  Run.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent


/// Single run of a root job
public struct Run: Model {
    
    public static let shared = Run()
    public static let entity = "runs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let scheduledId = Field<Speedster.DbIdType?>("scheduled_id")
    
    /// Job ID
    public let githubjobId = Field<Speedster.DbIdType?>("githubjob_id")
    
    /// Execution ID
    public let executionId = Field<Speedster.DbIdType?>("execution_id")
    
    /// Date started execution
    public let started = Field<Date?>("started")
    
    /// Date finished execution
    public let finished = Field<Date?>("finished")
    
    /// Result (exit code)
    public let result = Field<Int?>("result")
    
    /// Output log
    public let output = Field<String?>("output")
    
    /// Job name
    public let jobName = Field<String?>("job_name")
    
    /// Copy of the  job config
    public let job = Field<Root.Job?>("job")
    
}
