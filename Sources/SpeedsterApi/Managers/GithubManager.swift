//
//  GithubManager.swift
//  
//
//  Created by Ondrej Rafaj on 11/06/2019.
//

import GithubAPI
import AsyncKit


class GithubManager {
    
    struct SpeedsterFileData {
        
        enum Error: Swift.Error {
            case invalidSpeedsterFile
        }
        
        let org: String
        let repo: String
        let file: Data?
        
    }
    
    static func fileData(_ repos: [Repo], file: String = "Speedster.json", on c: Container) -> EventLoopFuture<[SpeedsterFileData]> {
        var futures: [EventLoopFuture<SpeedsterFileData>] = []
        do {
            for repo in repos {
                let future = try GithubAPI.File.query(on: c).get(organization: repo.owner.login, repo: repo.name, path: file).download(on: c).map({ data in
                    return SpeedsterFileData(
                        org: repo.owner.login,
                        repo: repo.name,
                        file: data
                    )
                }).recover({ error -> SpeedsterFileData in
                    return SpeedsterFileData(
                        org: repo.owner.login,
                        repo: repo.name,
                        file: nil
                    )
                })
                futures.append(future)
            }
        } catch {
            return c.eventLoop.makeFailedFuture(error)
        }
        return futures.flatten(on: c.eventLoop)
    }
    
}


extension GithubManager.SpeedsterFileData {
    
    var hasSpeedsteFile: Bool {
        return !(file?.isEmpty ?? true)
    }
    
    func asInfo() -> SpeedsterFileInfo {
        return SpeedsterFileInfo(
            org: org,
            repo: repo,
            speedster: hasSpeedsteFile
        )
    }
    
    func decodeCoreJob() throws -> SpeedsterCore.Job {
        guard let file = file else {
            throw Error.invalidSpeedsterFile
        }
        let data = try JSONDecoder().decode(SpeedsterCore.Job.self, from: file)
        return data
    }
    
}
