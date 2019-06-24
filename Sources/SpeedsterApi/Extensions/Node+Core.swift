//
//  Node+Core.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent
import SpeedsterCore


extension Row where Model == SpeedsterApi.Node {
    
    func asCore() throws -> SpeedsterCore.Node {
        let pass: String?
        if let p = self.password {
            pass = try Secrets.decrypt(p)
        }
        else { pass = nil }
        
        let key: String?
        if let k = self.publicKey { key = try Secrets.decrypt(k) }
        else { key = nil }
        
        return SpeedsterCore.Node(
            name: self.name,
            host: self.host,
            port: self.port,
            user: self.user,
            password: pass,
            publicKey: key,
            auth: .password
        )
    }
    
}
