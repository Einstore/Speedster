//
//  Root+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 14/07/2019.
//

import Foundation


extension Root {
    
    func requiredSoftware() -> [String] {
        var soft: [String] = []
        if source?.referenceRepo != nil {
            soft.append(ifNotPresent: "docker")
            soft.append(ifNotPresent: "git")
        }
        if source?.apiDownload != nil {
            soft.append(ifNotPresent: "curl")
        }
        if let image = environment?.image {
            switch image {
            case .docker:
                soft.append(ifNotPresent: "docker")
            case .vmware:
                soft.append(ifNotPresent: "vmrun")
            }
        }
        for job in jobs {
            if let image = job.environment?.image {
                switch image {
                case .docker:
                    soft.append(ifNotPresent: "docker")
                case .vmware:
                    soft.append(ifNotPresent: "vmrun")
                }
            }
        }
        if dockerDependendencies?.count ?? 0 > 0 {
            soft.append(ifNotPresent: "docker")
        }
        return soft
    }
    
}
