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
    
    enum Error: Swift.Error {
        case unableToRetrieveGithubData
        case invalidSpeedsterFile
    }
    
    struct SpeedsterFileData {
        let org: String
        let repo: String
        let file: Data?
    }
    
    let github: Github
    let database: Database
    let container: Container
    
    init(github: Github, container: Container, on database: Database) {
        self.github = github
        self.container = container
        self.database = database
    }
    
    fileprivate func hook(for url: String) -> Webhook.Post {
        let hook = Webhook.Post(
            active: true,
            events: [
                .all
            ],
            config: Webhook.Config(
                contentType: "json",
                insecureSSL: .no,
                url: url,
                secret: Environment.get("WEBHOOK_SECRET")
            )
        )
        return hook
    }
    
    func setup(webhooks infos: [SpeedsterFileInfo]) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for info in infos {
            do {
                let future: EventLoopFuture<Void> = try Webhook
                    .query(on: self.github)
                    .get(org: info.org, repo: info.repo)
                    .flatMap { hooks in
                        let url = "http://www.liveui.io/webhook"
                        if !hooks.contains(where: { $0.config.url == url }) {
                            let hook = self.hook(for: url)
                            do {
                                return try Webhook.query(on: self.github).create(org: info.org, repo: info.repo, hook: hook).void()
                            } catch {
                                return self.container.eventLoop.makeFailedFuture(error)
                            }
                        }
                        return self.container.eventLoop.future()
                }
                futures.append(future)
            } catch {
                futures.append(self.database.eventLoop.makeFailedFuture(error))
            }
        }
        return futures.flatten(on: self.database.eventLoop)
    }
    
    func reset(webhooks infos: [SpeedsterFileInfo]) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for info in infos {
            do {
                let future: EventLoopFuture<Void> = try Webhook
                    .query(on: self.github)
                    .get(org: info.org, repo: info.repo)
                    .flatMap { hooks in
                        let url = "http://www.liveui.io/webhook"
                        if let webhook = hooks.first(where: { $0.config.url == url }) {
                            let hook = self.hook(for: url)
                            do {
                                return try Webhook.query(on: self.github).edit(org: info.org, repo: info.repo, id: webhook.id, hook: hook).void()
                            } catch {
                                return self.container.eventLoop.makeFailedFuture(error)
                            }
                        } else {
                            let hook = self.hook(for: url)
                            do {
                                return try Webhook.query(on: self.github).create(org: info.org, repo: info.repo, hook: hook).void()
                            } catch {
                                return self.container.eventLoop.makeFailedFuture(error)
                            }
                        }
                }
                futures.append(future)
            } catch {
                futures.append(self.database.eventLoop.makeFailedFuture(error))
            }
        }
        return futures.flatten(on: self.database.eventLoop)
    }
    
    func update(orgStats orgs: [Row<Organization>]) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for org in orgs {
            let future: EventLoopFuture<Void> = Job.query(on: self.database)
                .join(\GitHubJob.jobId, to: \Job.id)
                .filter(\GitHubJob.organization == org.name)
                .count().flatMap { totalJobs in
                    return Job.query(on: self.database)
                        .join(\GitHubJob.jobId, to: \Job.id)
                        .filter(\GitHubJob.organization == org.name)
                        .filter(\Job.disabled == 0)
                        .count().flatMap { activeJobs in
                            org.activeJobs = activeJobs
                            org.totalJobs = totalJobs
                            return org.update(on: self.database)
                    }
            }
            futures.append(future)
        }
        return futures.flatten(on: self.database.eventLoop)
    }
    
    func process(files: [SpeedsterFileData], repos: [Repo]) -> EventLoopFuture<[SpeedsterFileInfo]> {
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
            
            let future = job.saveOnDb(fileInfo, container: container, on: database)
            futures.append(future)
        }
        return futures.flatten(on: self.container.eventLoop).map({ infos })
    }
    
    func resetWebhooks(webhooks infos: [SpeedsterFileInfo]) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func getCommitForSchedule(org: String, repo: String, branch: String? = nil) -> EventLoopFuture<Branch> {
        do {
            // TODO: Handle if someone doesn't have a master branch
            return try GitHubKit.Branch.query(on: github).get(org: org, repo: repo, branch: branch ?? "master")
        } catch {
            return container.eventLoop.makeFailedFuture(Error.unableToRetrieveGithubData)
        }
    }
    
    func fileData(_ repos: [Repo], file: String = "Speedster.yml") -> EventLoopFuture<[SpeedsterFileData]> {
        var futures: [EventLoopFuture<SpeedsterFileData>] = []
        do {
            let github = try container.make(Github.self)
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
            return container.eventLoop.makeFailedFuture(error)
        }
        return futures.flatten(on: container.eventLoop)
    }
    
    func disable(organization: Row<Organization>) -> EventLoopFuture<Void> {
        organization.disabled = 1
        organization.activeJobs = 0
        return organization.save(on: database).flatMap { _ in
            return Job.query(on: self.database)
                .join(\GitHubJob.jobId, to: \Job.id)
                .filter(\GitHubJob.organization == organization.name)
                .set(["disabled": .custom(true)])
                .update()
        }
    }
    
    func update(organizations githubOrgs: [GitHubKit.Organization]) -> EventLoopFuture<[Row<Organization>]> {
        return Organization.query(on: database).all().flatMap { dbOrgs in
            var futures: [EventLoopFuture<Row<Organization>>] = []
            
            var githubOrgsMutable = githubOrgs
            
            for dbOrg in dbOrgs {
                if !githubOrgsMutable.exists(dbOrg) {
                    let future = self.disable(organization: dbOrg).map({ dbOrg })
                    futures.append(future)
                } else {
                    guard let githubOrg = githubOrgsMutable.first(dbOrg) else {
                        continue
                    }
                    dbOrg.update(githubOrg)
                    let future = dbOrg.update(on: self.database).map({ dbOrg })
                    futures.append(future)
                }
                githubOrgsMutable.remove(dbOrg)
            }
            for githubOrg in githubOrgsMutable {
                let future = Organization.row(githubOrg, on: self.database).flatMap { org in
                    return org.save(on: self.database).map({ org })
                }
                futures.append(future)
            }
            
            return futures.flatten(on: self.database.eventLoop)
        }
    }
    
}


extension GithubManager.SpeedsterFileData {
    
    var hasSpeedsteFile: Bool {
        return !(file?.isEmpty ?? true)
    }
    
    func asInfo() -> SpeedsterFileInfo {
        return SpeedsterFileInfo(
            job: nil,
            org: org,
            repo: repo,
            speedster: hasSpeedsteFile,
            invalid: true,
            disabled: false
        )
    }
    
    func decodeCoreJob() throws -> SpeedsterCore.Job {
        guard let file = file, let string = String(data: file, encoding: .utf8) else {
            throw GithubManager.Error.invalidSpeedsterFile
        }
        let data = try YAMLDecoder().decode(SpeedsterCore.Job.self, from: string)
        return data
    }
    
}
