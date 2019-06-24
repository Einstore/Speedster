//
//  Scheduled.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Fluent
import SpeedsterCore


public struct GitReference: Codable {
    
    public enum RefType: String, Codable {
        case branch
        case commit
        case tag
    }
    
    public let value: String
    public let type: RefType
    
}

public struct GitLocation: Codable {
    
    public let org: String
    public let repo: String
    public let commit: String
    
}


/// Single run of a phase in a job
public struct Scheduled: Model {
    
    public struct Short: Content {
        
        public let id: Speedster.DbIdType?
        public let commit: String?
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
    
    /// Commit info
    public let commit = Field<String>("commit")
    
    /// Date requested execution
    public let requested = Field<Date>("requested")
    
}


extension Row where Model == Scheduled {
    
    public func asShort(managed: Bool? = nil) -> Scheduled.Short {
        return Scheduled.Short(self)
    }
    
}
