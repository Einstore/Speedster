//
//  Scheduled.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Fluent
import GitHubKit


/// Single run of a phase in a job
public struct Scheduled: Model {
    
    public struct Short: Content {
        
        public let id: Speedster.DbIdType?
        public let commit: Commit?
        public let requested: Date
        
        public init(_ row: Row<Scheduled>) {
            id = row.id
            commit = row.commit
            requested = row.requested
        }
        
    }
    
    public static let shared = Scheduled()
    public static let entity = "scheduled"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job ID
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Run ID (only available after job finishes)
    public let runId = Field<Speedster.DbIdType?>("run_id")
    
    /// Commit info
    public let commit = Field<Commit>("commit")
    
    /// Date requested execution
    public let requested = Field<Date>("requested")
    
    /// Github trigger data
    public let trigger = Field<Root.Pipeline.Trigger>("trigger")
    
}


extension Row where Model == Scheduled {
    
    public func asShort(managed: Bool? = nil) -> Scheduled.Short {
        return Scheduled.Short(self)
    }
    
}
