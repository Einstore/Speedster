//
//  Run.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent


/// Single run of a phase in a job
public struct Run: Model {
    
    public static let shared = Run()
    public static let entity = "runs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let scheduledId = Field<Speedster.DbIdType?>("scheduled_id")
    
    /// Job ID
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Node ID
    public let nodeId = Field<Speedster.DbIdType?>("node_id")
    
    /// Date started execution
    public let started = Field<Date?>("started")
    
    /// Date finished execution
    public let finished = Field<Date?>("finished")
    
    /// Result (exit code)
    public let result = Field<Int?>("result")
    
    /// Output log
    public let output = Field<String?>("output")
    
    /// Copy of the  Speedster file
    public let speedster = Field<Root?>("speedster")
    
}
