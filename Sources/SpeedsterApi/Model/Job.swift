//
//  Job.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent


/// Executable job, has phases and runs
public struct Job: Model {
    
    public struct Short: Content {
        
        public let name: String
        public let gitHub: SpeedsterCore.Job.GitHub?
        public let nodeLabels: [String]
        public let disabled: Bool
        public let managed: Bool?
        
        enum CodingKeys: String, CodingKey {
            case name
            case gitHub
            case nodeLabels = "node_labels"
            case disabled
            case managed
        }
        
        public init(_ row: Row<Job>, _ managed: Bool? = nil) {
            self.name = row.name
            self.gitHub = row.gitHub
            if let labels = row.nodeLabels {
                self.nodeLabels = labels.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
            } else {
                self.nodeLabels = []
            }
            self.disabled = row.disabled == 0 ? false : true
            self.managed = managed
        }
        
    }
    
    public static let shared = Job()
    public static let entity = "jobs"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job name
    public let name = Field<String>("name")
    
    /// GitHub info & settings
    public let gitHub = Field<SpeedsterCore.Job.GitHub?>("github")

    /// Disable job; if a Speedster.yml is deleted from an automatically managed repo, Job will get disabled
    public let disabled = Field<Int>("disabled")
    
    /// Node labels
    public let nodeLabels = Field<String?>("node_labels")
    
    /// Script to start environment
    public let environmnetStart = Field<String?>("environmnet_start")
    
    /// Script to stop environment
    public let environmnetFinish = Field<String?>("environmnet_finish")
    
    /// Automatically managed should there be any content
    public let speedsterFile = Field<SpeedsterCore.Job?>("speedster_file")
    
    /// Automatically managed should there be any content
    public let dockerDependendencies = Field<[SpeedsterCore.Job.Dependency]?>("docker_dependendencies")

}


extension Row where Model == Job {
    
    public func asShort(managed: Bool? = nil) -> Job.Short {
        return Job.Short(self, managed)
    }
    
}


extension Array where Element == Row<Job> {
    
    @inlinable public func map<T>(toResponse status: HTTPStatus = .ok, headers: HTTPHeaders = [:], transform: (Element) throws -> T) rethrows -> Response where T: Encodable {
        return try map({ try transform($0) }).asDisplayResponse()
    }
    
}
