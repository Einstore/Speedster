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
        case noFilesFoundInCommitTree
        case missingSpeedsterFile
    }
    
    struct SpeedsterFileData {
        let org: String
        let repo: String
        let file: Data?
    }
    
    let github: Github
    let db: Database
    let container: Container
    
    init(github: Github, container: Container, on database: Database) {
        self.github = github
        self.container = container
        self.db = database
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
                futures.append(self.db.eventLoop.makeFailedFuture(error))
            }
        }
        return futures.flatten(on: self.db.eventLoop)
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
                futures.append(self.db.eventLoop.makeFailedFuture(error))
            }
        }
        return futures.flatten(on: self.db.eventLoop)
    }
    
    func update(orgStats orgs: [Row<Organization>]) -> EventLoopFuture<Void> {
        var futures: [EventLoopFuture<Void>] = []
        for org in orgs {
            let future: EventLoopFuture<Void> = Root.query(on: self.db)
                .join(\GitHubJob.jobId, to: \Root.id)
                .filter(\GitHubJob.organization == org.name)
                .count().flatMap { totalJobs in
                    return Root.query(on: self.db)
                        .join(\GitHubJob.jobId, to: \Root.id)
                        .filter(\GitHubJob.organization == org.name)
                        .filter(\Root.disabled == 0)
                        .count().flatMap { activeJobs in
                            org.activeJobs = activeJobs
                            org.totalJobs = totalJobs
                            return org.update(on: self.db)
                    }
            }
            futures.append(future)
        }
        return futures.flatten(on: self.db.eventLoop)
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
            
            let future = job.saveOnDb(fileInfo, github: github, on: db)
            futures.append(future)
        }
        return futures.flatten(on: self.container.eventLoop).map({ infos })
    }
    
    func resetWebhooks(webhooks infos: [SpeedsterFileInfo]) -> EventLoopFuture<Void> {
        fatalError()
    }
    
    func getCommitForSchedule(org: String, repo: String, ref: Scheduled.Ref? = nil) -> EventLoopFuture<Commit> {
        do {
            guard let ref = ref else {
                return try GitHubKit.Branch.query(on: github).get(org: org, repo: repo, branch: "master").latestCommit()
            }
            switch ref.type {
            case .branch:
                return try GitHubKit.Branch.query(on: github).get(org: org, repo: repo, branch: ref.value).latestCommit()
            case .tag:
                fatalError("Tag not supported yet")
            //                return try GitHubKit.Branch.query(on: github).get(org: org, repo: repo, branch: ref.value).latestCommit()
            case .commit:
                return try GitHubKit.Commit.query(on: github).get(org: org, repo: repo, sha: ref.value)
            }
        } catch {
            return container.eventLoop.makeFailedFuture(Error.unableToRetrieveGithubData)
        }
    }
    
    func blob(_ fileName: String, for location: SpeedsterCore.Job.GitHub.Location) -> EventLoopFuture<GitBlob> {
        guard let commit = location.commit else {
            return self.db.eventLoop.makeFailedFuture(GenericError.decodingError)
        }
        do {
            return try GitHubKit.GitCommit.query(on: self.github).get(
                org: location.organization,
                repo: location.repo,
                sha: commit
                ).flatMap { commit in
                    do {
                        return try GitHubKit.GitTree.query(on: self.github).get(
                            org: location.organization,
                            repo: location.repo,
                            sha: commit.tree.sha
                            ).flatMap { tree in
                                guard let objects = tree.objects else {
                                    return self.db.eventLoop.makeFailedFuture(Error.noFilesFoundInCommitTree)
                                }
                                
                                for object in objects {
                                    guard object.path == fileName else {
                                        continue
                                    }
                                    do {
                                        return try GitHubKit.GitBlob.query(on: self.github).get(
                                            org: location.organization,
                                            repo: location.repo,
                                            sha: object.sha
                                            )
                                    } catch {
                                        return self.db.eventLoop.makeFailedFuture(error)
                                    }
                                }
                                return self.db.eventLoop.makeFailedFuture(Error.missingSpeedsterFile)
                        }
                    } catch {
                        return self.db.eventLoop.makeFailedFuture(error)
                    }
            }
        } catch {
            return db.eventLoop.makeFailedFuture(error)
        }
    }
    
    func file(_ fileName: String, for location: SpeedsterCore.Job.GitHub.Location) -> EventLoopFuture<Data> {
        return blob(fileName, for: location).flatMap { blob in
            guard let data = Data(base64Encoded: blob.content, options: [.ignoreUnknownCharacters]) else {
                return self.db.eventLoop.makeFailedFuture(GenericError.decodingError)
            }
            return self.db.eventLoop.makeSucceededFuture(data)
        }
    }
    
    func speedster(for location: SpeedsterCore.Job.GitHub.Location) -> EventLoopFuture<SpeedsterCore.Job> {
        return blob("Speedster.yml", for: location).flatMap { blob in
            do {
                guard
                    let data = Data(base64Encoded: blob.content, options: [.ignoreUnknownCharacters]),
                    let string = String(data: data, encoding: .utf8),
                    let job: SpeedsterCore.Job = try YAMLDecoder().decode(from: string)
                    else {
                        return self.db.eventLoop.makeFailedFuture(GenericError.decodingError)
                }
                return self.db.eventLoop.makeSucceededFuture(job)
            } catch {
                return self.db.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    // TODO: Re-evaluate, following method seems to do the same as the previous one!!!!
    func fileData(_ repos: [Repo], file: String = "Speedster.yml") -> EventLoopFuture<[SpeedsterFileData]> {
        var futures: [EventLoopFuture<SpeedsterFileData>] = []
        do {
            for repo in repos {
                let future = try GitHubKit.File.query(on: github).get(org: repo.owner.login, repo: repo.name, path: file).download(on: github).map({ data in
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
        return organization.save(on: db).flatMap { _ in
            return Root.query(on: self.db)
                .join(\GitHubJob.jobId, to: \Root.id)
                .filter(\GitHubJob.organization == organization.name)
                .set(["disabled": .custom(true)])
                .update()
        }
    }
    
    func update(organizations githubOrgs: [GitHubKit.Organization]) -> EventLoopFuture<[Row<Organization>]> {
        return Organization.query(on: db).all().flatMap { dbOrgs in
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
                    let future = dbOrg.update(on: self.db).map({ dbOrg })
                    futures.append(future)
                }
                githubOrgsMutable.remove(dbOrg)
            }
            for githubOrg in githubOrgsMutable {
                let future = Organization.row(githubOrg, on: self.db).flatMap { org in
                    return org.save(on: self.db).map({ org })
                }
                futures.append(future)
            }
            
            return futures.flatten(on: self.db.eventLoop)
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
