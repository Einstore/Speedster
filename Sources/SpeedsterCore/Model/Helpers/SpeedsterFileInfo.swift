//
//  SpeedsterFileInfo.swift
//  
//
//  Created by Ondrej Rafaj on 11/06/2019.
//

import Vapor


struct SpeedsterFileInfo: Content {
    let job: Speedster.DbIdType?
    let org: String
    let repo: String
    let speedster: Bool
    var invalid: Bool
    var disabled: Bool
}
