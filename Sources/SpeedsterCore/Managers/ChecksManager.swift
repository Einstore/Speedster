//
//  ChecksManager.swift
//  
//
//  Created by Ondrej Rafaj on 02/07/2019.
//

import Foundation


class ChecksManager {
    
    enum Error: Swift.Error, Equatable {
        case dependentJobDoesNotExist(String)
        case dependentJobNotListed(String)
    }
    
    @discardableResult static func check(jobDependencies root: Root) throws -> Bool {
        func dep(for name: String) throws -> Root.Job {
            guard let depJob = root.jobs.first(where: { $0.name == name }) else {
                throw Error.dependentJobDoesNotExist(name)
            }
            return depJob
        }
        
        func deps(job: Root.Job, arr: [String] = []) throws -> [String] {
            if let dependency = job.dependsOn {
                let depJob = try dep(for: dependency)
                var dependencies = try deps(job: depJob, arr: arr)
                dependencies.append(contentsOf: arr)
                return dependencies
            }
            return []
        }
        
        for pipeline in root.pipelines ?? [] {
            for pipelineJob in pipeline.jobs {
                let job = try dep(for: pipelineJob)
                let arr = try deps(job: job)
                for depJob in arr {
                    if !pipeline.jobs.contains(depJob) {
                        throw Error.dependentJobNotListed(depJob)
                    }
                }
            }
        }
        for job in root.jobs {
            let dependencies = try deps(job: job)
            for dependency in dependencies {
                if !root.jobs.contains(where: { $0.name == dependency }) {
                    throw Error.dependentJobDoesNotExist(dependency)
                }
            }
        }
        return true
    }
    
}
