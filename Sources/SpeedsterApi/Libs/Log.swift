//
//  Log.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent


class Log {
    
    private static func fileName(_ run: Row<Run>) throws -> String {
        guard let id = run.id?.uuidString else {
            throw DbError.unknownId
        }
        return "/tmp/\(id.lowercased()).log"
    }
    
    static func get(_ run: Row<Run>) throws -> String? {
        let path = try fileName(run)
        let text = try String(contentsOfFile: path)
        return text
    }
    
    static func write(_ text: String, to run: Row<Run>) throws {
        let path = try fileName(run)
        try text.write(toFile: path, atomically: true, encoding: .utf8)
    }
    
    static func clear(_ run: Row<Run>) throws {
        let path = try fileName(run)
        try FileManager.default.removeItem(atPath: path)
    }
    
}
