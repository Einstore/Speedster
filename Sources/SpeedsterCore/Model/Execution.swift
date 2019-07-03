//
//  Execution.swift
//  
//
//  Created by Ondrej Rafaj on 03/07/2019.
//

import Fluent


/// Single run of a root job
public struct Execution: Model {
    
    public static let shared = Execution()
    public static let entity = "executions"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let scheduledId = Field<Speedster.DbIdType?>("scheduled_id")
    
    /// Job ID
    public let githubjobId = Field<Speedster.DbIdType?>("githubjob_id")
    
    /// Node ID
    public let nodeId = Field<Speedster.DbIdType?>("node_id")
    
    /// Date started execution
    public let started = Field<Date?>("started")
    
    /// Date finished execution
    public let finished = Field<Date?>("finished")
    
}

