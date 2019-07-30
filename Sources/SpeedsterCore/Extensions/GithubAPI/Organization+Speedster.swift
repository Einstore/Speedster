import GitHubKit
import Fluent


extension GitHubKit.Organization {
    
    /// Update Organization row with data from API
    func update(_ organization: Row<Organization>) {
        organization.name = login
        organization.githubId = id
        organization.displayName = name ?? login
        organization.company = company
        organization.icon = avatarURL
        organization.full = self
        organization.server = "http://some_enterprise_server.com"
        organization.disabled = 0
    }
    
}

extension Row where Model == Organization {
    
    /// Update Organization row with data from API
    func update(_ organization: GitHubKit.Organization) {
        organization.update(self)
    }
    
}


extension Array where Element == GitHubKit.Organization {
    
    func repos(on c: Container) -> EventLoopFuture<[Repo]> {
        var futures: [EventLoopFuture<[Repo]>] = []
        for org in self {
            do {
                let github = try c.make(Github.self)
                let future = try Repo.query(on: github).get(org: org.login)
                futures.append(future)
            } catch {
                return c.eventLoop.makeFailedFuture(error)
            }
        }
        return futures.flatten(on: c.eventLoop).map { reposArr in
            let repos = reposArr.reduce([], +)
            return repos
        }
    }
    
    func exists(_ org: Row<Organization>) -> Bool {
        return filter({ $0.login == org.name }).count > 0
    }
    
    func first(_ org: Row<Organization>) -> GitHubKit.Organization? {
        return filter({ $0.login == org.name }).first
    }
    
    mutating func remove(_ org: Row<Organization>) {
        removeAll(where: { $0.login == org.name })
    }
    
}


extension Organization {
    
    /// Return a guaranteed Organization row
    static func row(_ organization: GitHubKit.Organization, on db: Database) -> EventLoopFuture<Row<Organization>> {
        return Organization.query(on: db).filter(\Organization.githubId == organization.id).first().map() { org in
            guard let org = org else {
                let row = Organization.row()
                row.activeJobs = 0
                row.totalJobs = 0
                
                organization.update(row)
                return row
            }
            organization.update(org)
            return org
        }
    }
    
    
    
}
