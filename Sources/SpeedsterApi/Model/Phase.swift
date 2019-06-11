//
//  Phase.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent
import SpeedsterCore


/// Build phase of a job
public struct Phase: Model {
    
    public enum Stage: Int, Codable {
        
        /// Build phase
        case build = 0
        
        /// Pre-build phase
        case pre = 1
        
        /// Post-build phase
        case post = 2
        
    }
    
    public static let shared = Phase()
    public static let entity = "phases"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job relation
    public let jobId = Field<Speedster.DbIdType?>("job_id")
    
    /// Name of the job
    public let name = Field<String>("name")
    
    /// Order in which Phase should be displayed
    public let order = Field<Int>("order")
    
    /// Command to be executed
    public let command = Field<String>("command")
    
    /// Phase description, informative only
    public let descriptionText = Field<String>("description")
    
    /// Stage (pre-build => setup environment, build, post-build => clear environment)
    public let stage = Field<Stage>("stage", dataType: .int)

}


extension Phase {
    
    static func row(from phase: SpeedsterCore.Job.Phase, jobId: Speedster.DbIdType, order: Int, stage: Phase.Stage) -> Row<Phase> {
        let row = Phase.row()
        row.jobId = jobId
        row.name = phase.name
        row.order = order
        row.command = phase.command
        row.descriptionText = phase.description
        row.stage = stage
        return row
    }
    
}
