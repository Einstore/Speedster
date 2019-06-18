//
//  Scheduled.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Fluent
import SpeedsterCore


/// Single run of a phase in a job
public struct Scheduled: Model {
    
    public static let shared = Scheduled()
    public static let entity = "scheduled"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Github info
    public let github = Field<SpeedsterCore.Job.GitHub?>("github")
    
    /// Date requested execution
    public let requested = Field<Date>("requested")
    
}
