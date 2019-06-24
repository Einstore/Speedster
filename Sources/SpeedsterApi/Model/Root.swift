//
//  Root.swift
//  
//
//  Created by Ondrej Rafaj on 07/06/2019.
//

import Fluent


/// Executable job, has phases and runs
public struct Root: Model {
    
    public struct Short: Content {
        
        public let id: Speedster.DbIdType?
        public let name: String
        public let gitHub: SpeedsterCore.Root.GitHub?
        public let nodeLabels: [String]?
        public let disabled: Bool
        public let managed: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case gitHub
            case nodeLabels = "node_labels"
            case disabled
            case managed
        }
        
        public init(_ row: Row<Root>, _ managed: Bool? = nil) {
            self.id = row.id
            self.name = row.name
            self.gitHub = row.gitHub
            if let labels = row.nodeLabels, !labels.isEmpty {
                self.nodeLabels = labels.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
            } else {
                self.nodeLabels = []
            }
            self.disabled = row.disabled == 0 ? false : true
            self.managed = managed
        }
        
    }
    
    public static let shared = Root()
    public static let entity = "roots"
    
    public let id = Field<Speedster.DbIdType?>("id")
    
    /// Job name
    public let name = Field<String>("name")
    
    /// GitHub info & settings
    public let gitHub = Field<SpeedsterCore.Root.GitHub?>("github")

    /// Disable job; if a Speedster.yml is deleted from an automatically managed repo, Job will get disabled
    public let disabled = Field<Int>("disabled")
    
    /// Node labels
    public let nodeLabels = Field<String?>("node_labels")
    
    /// Script to start environment
    public let environment = Field<SpeedsterCore.Root.Env?>("environment")
    
    /// Automatically managed should there be any content
    public let speedsterFile = Field<SpeedsterCore.Root?>("speedster_file")
    
    /// Automatically managed should there be any content
    public let dockerDependendencies = Field<[SpeedsterCore.Root.Dependency]?>("docker_dependendencies")
    
    /// Pipelines (trigger workflows)
    public let pipelines = Field<[SpeedsterCore.Root.Pipeline]?>("pipelines")

}


extension Row where Model == Root {
    
    public func asShort(managed: Bool? = nil) -> Root.Short {
        return Root.Short(self, managed)
    }
    
}


extension Array where Element == Row<Root> {
    
    @inlinable public func map<T>(toResponse status: HTTPStatus = .ok, headers: HTTPHeaders = [:], transform: (Element) throws -> T) rethrows -> Response where T: Encodable {
        return try map({ try transform($0) }).asDisplayResponse()
    }
    
}
