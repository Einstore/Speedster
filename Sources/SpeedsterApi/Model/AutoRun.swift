//
//  AutoRun.swift
//  
//
//  Created by Ondrej Rafaj on 16/06/2019.
//

import Fluent
import SpeedsterCore


// Node is a single worker machine to which Speedster connects via SSH
public struct AutoRun: Model {
    
    public static let shared = AutoRun()
    public static let entity = "autoruns"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Node name
    public let autoJobId = Field<Speedster.DbIdType?>("autojob_id")
    
    /// Date started execution
    public let date = Field<Date>("date")
    
    /// Date finished execution
    public let finished = Field<Date>("finished")
    
    /// Result (exit code)
    public let result = Field<Int>("result")
    
    /// Port to connect to
    public let speedster = Field<SpeedsterCore.Job>("speedster")
    
}

