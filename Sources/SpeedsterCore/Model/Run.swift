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
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    public let phaseId = Field<Speedster.DbIdType?>("phase_id")
    public let nodeId = Field<Speedster.DbIdType?>("node_id")
    public let date = Field<Date>("date")
    public let result = Field<Bool>("result")
    public let output = Field<String>("output")
    
}
