//
//  Run.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import Vapor


/// Single run of a phase in a job
public struct Run: Model {
    
    public static let shared = Run()
    public static let entity = "runs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Phase ID
    public let phaseId = Field<Speedster.DbIdType?>("phase_id")
    
    /// Node ID
    public let nodeId = Field<Speedster.DbIdType?>("node_id")
    
    /// Date started execution
    public let date = Field<Date>("date")
    
    /// Date finished execution
    public let finished = Field<Date>("finished")
    
    /// Result (exit code)
    public let result = Field<Int>("result")
    
    /// Output log
    public let output = Field<String>("output")
    
}
