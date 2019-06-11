//
//  SpeedsterFileInfo.swift
//  
//
//  Created by Ondrej Rafaj on 11/06/2019.
//

import Vapor


struct SpeedsterFileInfo: Content {
    let org: String
    let repo: String
    let speedster: Bool
}
