//
//  Phase.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import Vapor


/// Build phase of a job
public struct Phase: Model {
    
    public static let shared = Phase()
    public static let entity = "phases"
    
    public let id = Field<Speedster.DbIdType?>("id")
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    public let name = Field<String>("name")
    public let order = Field<Int8>("order")
    public let command = Field<String>("command")
    public let description = Field<String>("description")
    
}
