//
//  GithubManager.swift
//  
//
//  Created by Ondrej Rafaj on 11/06/2019.
//

import GitHubKit
import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Yams


class GithubManager {
    
    struct SpeedsterFileData {
        
        enum Error: Swift.Error {
            case invalidSpeedsterFile
        }
        
        let org: String
        let repo: String
        let file: Data?
        
    }
    
    static func setup(webhooks repo: SpeedsterCore.Job.GitHub, on c: Container) -> EventLoopFuture<Void> {
        return c.eventLoop.future()
    }
    
    static func fileData(_ repos: [Repo], file: String = "Speedster.yml", on c: Container) -> EventLoopFuture<[SpeedsterFileData]> {
        var futures: [EventLoopFuture<SpeedsterFileData>] = []
        do {
            let github = try c.make(Github.self)
            for repo in repos {
                let future = try GitHubKit.File.query(on: github).get(organization: repo.owner.login, repo: repo.name, path: file).download(on: github).map({ data in
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
    
    static func disable(organization: Row<Organization>, on db: Database) -> EventLoopFuture<Void> {
        organization.disabled = 1
        organization.activeJobs = 0
        return organization.save(on: db).flatMap { _ in
            return Job.query(on: db)
                .join(\GitHubJob.jobId, to: \Job.id)
                .filter(\GitHubJob.organization == organization.name)
                .set(["disabled": .custom(true)])
                .update()
        }
    }
    
    static func update(organizations githubOrgs: [GitHubKit.Organization], on db: Database) -> EventLoopFuture<[Row<Organization>]> {
        return Organization.query(on: db).all().flatMap { dbOrgs in
            var futures: [EventLoopFuture<Row<Organization>>] = []
            
            var githubOrgsMutable = githubOrgs
            
            for dbOrg in dbOrgs {
                if !githubOrgsMutable.exists(dbOrg) {
                    let future = disable(organization: dbOrg, on: db).map({ dbOrg })
                    futures.append(future)
                } else {
                    guard let githubOrg = githubOrgsMutable.first(dbOrg) else {
                        continue
                    }
                    dbOrg.update(githubOrg)
                    let future = dbOrg.update(on: db).map({ dbOrg })
                    futures.append(future)
                }
                githubOrgsMutable.remove(dbOrg)
            }
            for githubOrg in githubOrgsMutable {
                let future = Organization.row(githubOrg, on: db).flatMap { org in
                    return org.save(on: db).map({ org })
                }
                futures.append(future)
            }
            
            return futures.flatten(on: db.eventLoop)
        }
    }
    
    static func process(files: [SpeedsterFileData], repos: [Repo], on system: System) -> EventLoopFuture<[SpeedsterFileInfo]> {
        var infos: [SpeedsterFileInfo] = []
        var futures: [EventLoopFuture<Void>] = []
        for file in files {
            guard file.hasSpeedsteFile else {
                continue
            }
            var fileInfo = file.asInfo()
            let decodedJob: SpeedsterCore.Job?
            if let repo = repos.first(where: { $0.name == file.repo && $0.owner.login == file.org }), repo.archived == true {
                fileInfo.disabled = true
                decodedJob = nil
            } else {
                fileInfo.disabled = false
                do {
                    decodedJob = try file.decodeCoreJob()
                    fileInfo.invalid = false
                } catch {
                    decodedJob = nil
                }
            }
            infos.append(fileInfo)
            
            guard let job = decodedJob else {
                continue
            }
            
            let future = job.saveOnDb(fileInfo, on: system)
            futures.append(future)
        }
        return futures.flatten(on: system.db.eventLoop).map({ infos })
    }
    
    static func updateOrgStats(_ orgs: [Row<Organization>], on db: Database) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for org in orgs {
            let future: EventLoopFuture<Void> = Job.query(on: db)
                .join(\GitHubJob.jobId, to: \Job.id)
                .filter(\GitHubJob.organization == org.name)
                .count().flatMap { totalJobs in
                    return Job.query(on: db)
                        .join(\GitHubJob.jobId, to: \Job.id)
                        .filter(\GitHubJob.organization == org.name)
                        .filter(\Job.disabled == 0)
                        .count().flatMap { activeJobs in
                            org.activeJobs = activeJobs
                            org.totalJobs = totalJobs
                            return org.update(on: db)
                    }
            }
            futures.append(future)
        }
        return futures.flatten(on: db.eventLoop)
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
            speedster: hasSpeedsteFile,
            invalid: true,
            disabled: false
        )
    }
    
    func decodeCoreJob() throws -> SpeedsterCore.Job {
        guard let file = file, let string = String(data: file, encoding: .utf8) else {
            throw Error.invalidSpeedsterFile
        }
        let data = try YAMLDecoder().decode(SpeedsterCore.Job.self, from: string)
        return data
    }
    
}
