//
//  Node+Core.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import Fluent
import SpeedsterCore


extension Row where Model == SpeedsterApi.Node {
    
    func asCore() throws -> SpeedsterCore.Machine {
        let pass: String?
        if let p = self.password {
            do { pass = try Secrets.decrypt(p) } catch { pass = nil }
        }
        else { pass = nil }
        
        let key: String?
        if let k = self.publicKey { key = try Secrets.decrypt(k) }
        else { key = nil }
        
        return SpeedsterCore.Machine(
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
