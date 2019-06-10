//
//  Github.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Vapor


public protocol GithubServerConvertible {
    var value: String { get }
}

public enum GithubServer: GithubServerConvertible {
    
    case github
    case enterprise(String)
    
    public var value: String {
        switch self {
        case .github:
            return "https://api.github.com"
        case .enterprise(let url):
            return url
        }
    }
}

public class Github {
    
    public struct Config {
        
        public let username: String
        public let token: String
        public let server: GithubServerConvertible
        
        public init(username: String, token: String, server: GithubServerConvertible = GithubServer.github) {
            self.username = username
            self.token = token
            self.server = server
        }
    }
    
    public let config: Config
    
    let client: Client
    
    public init(_ config: Config, on c: Container) throws {
        self.config = config
        self.client = try c.make()
    }
    
}


extension Github {
    
    func get<C>(_ o: C.Type, path: String) throws -> EventLoopFuture<C?> where C: Decodable {
        let uri = URI(string: config.url(for: path))
        
//        let loginString = "\(config.username):\(config.token)"
//        let loginData = loginString.data(using: String.Encoding.utf8)!
//        let base64LoginString = loginData.base64EncodedString()
        
        let base64LoginString = "b3JhZmFqOjZhZTJjYThlOGE5MTkwYmU4ZmI2YTg2NGFhZWFhM2IwZWNiZjFiOWE="
        
        return client.get(uri, headers: ["Authorization": "Basic \(base64LoginString)"]).map() { response in
            let data = try? response.content.decode(C.self)
            return data
        }
    }
    
}


extension String: GithubServerConvertible {
    
    public var value: String {
        return self
    }
    
}


extension Github.Config {
    
    func url(for path: String) -> String {
        return server.value.finished(with: "/").appending(path)
    }
    
}
