//
//  Author.swift
//  
//
//  Created by Ondrej Rafaj on 23/06/2019.
//

import Foundation


public struct VM: Codable {
    
    public struct Put: Codable {
        public let processors: Int?
        public let memory: Int?
    }
    
    public struct Post: Codable {
        public let name: String?
        public let parentId: String?
    }
    
    public struct Power: Codable {
        
        public enum Put: String, Codable {
            case on, off, shutdown, suspend, pause, unpause
        }
        
        public let powerState: String
        
        enum CodingKeys: String, CodingKey {
            case powerState = "power_state"
        }
        
    }
    
    public struct IP: Codable {
        
        let value: String
        
        enum CodingKeys: String, CodingKey {
            case value = "ip"
        }
        
    }
    
    public struct SharedFolder: Codable {
        
        public let id: String
        public let hostPath: String
        public let flags: Int
        
        enum CodingKeys: String, CodingKey {
            case id = "folder_id"
            case hostPath = "host_path"
            case flags = "flags"
        }
        
    }

    public struct CPU: Codable {
        let processors: Int?
    }
    
    public let id: String?
    public let path: String?
    public let cpu: CPU?
    public let memory: Int?
    
}
