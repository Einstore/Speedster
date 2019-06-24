//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 24/06/2019.
//

import Foundation


struct Scripts {
    
    static var machine: String {
        return """
            unameOut="$(uname -s)"
            case "${unameOut}" in
            Linux*)     machine=Linux;;
            Darwin*)    machine=Mac;;
            CYGWIN*)    machine=Cygwin;;
            MINGW*)     machine=MinGw;;
            *)          machine="UNKNOWN:${unameOut}"
            esac
            echo ${machine}
            """
    }
    
}
