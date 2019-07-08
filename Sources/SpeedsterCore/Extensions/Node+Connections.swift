//
//  Node+Connections.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent
import ShellKit


extension Row where Model == Node {
    
    func asShellConnection() throws -> Shell.Connection {
        switch true {
        case self.host == "localhost", self.host == "127.0.0.1", self.host == "0.0.0.0":
            return .local
        case self.auth == .password:
            let password: String?
            if let data = self.password {
                password = try Secrets.decrypt(data)
            } else { password = nil }
            return .ssh(host: self.host, username: self.user ?? "root", password: password ?? "")
        default:
            throw GenericError.notSupported("Only local nodes and remote nodes authenticated with username and password are supported")
        }
    }
    
}
