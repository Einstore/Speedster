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
    
    public struct Wrapper: Content {
        public let job: Root.Short
        public let scheduled: Scheduled.Short?
    }
    
    public struct Short: Content {
        
        public let id: Speedster.DbIdType?
        public let github: SpeedsterCore.Job.GitHub?
        public let requested: Date
        
        public init(_ row: Row<Scheduled>) {
            id = row.id
            github = row.github
            requested = row.requested
        }
        
    }
    
    public struct Ref: Codable {
        
        public enum RefType: String, Codable {
            case branch
            case commit
            case tag
        }
        
        public let value: String
        public let type: RefType
        
    }
    
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


extension Row where Model == Scheduled {
    
    public func asShort(managed: Bool? = nil) -> Scheduled.Short {
        return Scheduled.Short(self)
    }
    
}
