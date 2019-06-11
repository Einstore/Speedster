//
//  GithubController.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Vapor
import Fluent
import GithubAPI

import AsyncKit


final class GithubController: Controller {
    
    enum GithubError: Error {
        case unknownOrg
    }
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {        
        r.get("github", "reload") { req -> EventLoopFuture<[SpeedsterFileInfo]> in
            return try GithubAPI.Organization.query(on: c).getAll().flatMap() { orgs in
                return orgs.repos(on: c).flatMap { repos in
                    return GithubManager.fileData(repos, on: c).flatMap { files in
                        var infos: [SpeedsterFileInfo] = []
                        var futures: [EventLoopFuture<Row<Job>>] = []
                        for file in files {
                            guard file.hasSpeedsteFile else {
                                continue
                            }
                            var fileInfo = file.asInfo()
                            let decodedJob: SpeedsterCore.Job?
                            do {
                                decodedJob = try file.decodeCoreJob()
                                fileInfo.invalid = false
                            } catch {
                                decodedJob = nil
                            }
                            infos.append(fileInfo)
                            
                            guard let job = decodedJob else {
                                continue
                            }
                            let future = job.guaranteedDbJobRowForAutomaticManagement(org: file.org, repo: file.repo, on: self.db)
                            futures.append(future)
                        }
                        return futures.flatten(on: c.eventLoop).map { _ in
                            return infos
                        }
                    }
                }
            }
        }
    }
    
}
