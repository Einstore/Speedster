//
//  VM.swift
//  
//
//  Created by Ondrej Rafaj on 13/06/2019.
//

import NIO


extension VM: Queryable { }


extension QueryableProperty where QueryableType == VM {
    
    /// Get VM's
    public func get() throws -> EventLoopFuture<[VM]> {
        return try fusion.get(path: "vms")
    }
    
    /// Get a specific VM
    public func get(_ id: String) throws -> EventLoopFuture<VM> {
        return try fusion.get(path: "vms/\(id)")
    }
    
    /// Update a specific VM
    public func update(_ id: String, data: VM.Put) throws -> EventLoopFuture<VM?> {
        return try fusion.put(path: "vms/\(id)", post: data)
    }
    
    /// Create a VM
    public func create(_ data: VM.Post) throws -> EventLoopFuture<VM?> {
        return try fusion.post(path: "vms", post: data)
    }
    
    /// Delete a specific VM
    public func delete(_ id: String) throws -> EventLoopFuture<Void> {
        return try fusion.delete(path: "vms/\(id)")
    }
    
    /// Get VM IP
    public func ip(_ id: String) throws -> EventLoopFuture<VM.IP> {
        return try fusion.get(path: "vms/\(id)/ip")
    }
    
    /// Get shared folders
    public func shared(folders id: String) throws -> EventLoopFuture<[VM.SharedFolder]> {
        return try fusion.get(path: "vms/\(id)/sharedfolders")
    }
    
    /// Create a shared folder
    public func shared(folder id: String, new data: VM.SharedFolder) throws -> EventLoopFuture<[VM.SharedFolder]?> {
        return try fusion.post(path: "vms/\(id)/sharedfolders", post: data)
    }
    
    /// Delete a specific shared folder
    public func delete(_ id: String, sharedFolder folderId: String) throws -> EventLoopFuture<Void> {
        return try fusion.delete(path: "vms/\(id)sharedfolders/\(folderId)")
    }
    
    /// Get power status of a specific VM
    public func power(_ id: String) throws -> EventLoopFuture<VM.Power> {
        return try fusion.get(path: "vms/\(id)/power")
    }
    
    /// Change power status of a specific VM
    public func change(_ id: String, power state: VM.Power.Put) throws -> EventLoopFuture<Void> {
        let ret: EventLoopFuture<String?> = try fusion.put(path: "vms/\(id)/power", plain: state.rawValue)
        return ret.map({ _ in
            return Void()
        })
    }
    
}
