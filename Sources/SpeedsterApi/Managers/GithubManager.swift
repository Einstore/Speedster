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
        let org: String
        let repo: String
        let file: Data?
    }
    
    static func fileData(_ repos: [Repo], on c: Container) -> EventLoopFuture<[SpeedsterFileData]> {
        var futures: [EventLoopFuture<SpeedsterFileData>] = []
        do {
            for repo in repos {
                let future = try GithubAPI.File.query(on: c).get(organization: repo.owner.login, repo: repo.name, path: "README.md").download(on: c).map({ data in
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
    
    func asInfo() -> SpeedsterFileInfo {
        return SpeedsterFileInfo(
            org: org,
            repo: repo,
            speedster: !(file?.isEmpty ?? true)
        )
    }
    
}
