//
//  VMWareRest.swift
//  
//
//  Created by Ondrej Rafaj on 10/06/2019.
//

import Foundation
import NIO
import NIOHTTP1
import NIOHTTPClient


/// Server value convertible
public protocol VMWareRestServerConvertible {
    var value: String { get }
}

/// Main VMWareRest service class
public class VMWareRest {
    
    public enum Error: Swift.Error {
        
        case fileNotFound(String)
        
        case invalidContent
        
    }
    
    /// Main configuration
    public struct Config {
        
        /// Username
        public let username: String
        
        /// Password
        public let password: String
        
        /// Server URL
        public let server: VMWareRestServerConvertible
        
        /// Initializer
        public init(username: String, password: String, server: VMWareRestServerConvertible) {
            self.username = username
            self.password = password
            self.server = server
        }
        
    }
    
    /// Copy of the given configuration
    public let config: Config
    
    let client: HTTPClient
    
    /// Initializer
    public init(_ config: Config, eventLoopGroupProvider provider: EventLoopGroupProvider = .createNew) throws {
        self.config = config
        self.client = HTTPClient(eventLoopGroupProvider: provider)
    }
    
    /// Initializer
    public init(_ config: Config, eventLoop: EventLoop) throws {
        self.config = config
        self.client = HTTPClient(eventLoopGroupProvider: .shared(eventLoop))
    }
    
    var eventLoop: EventLoop {
        return client.eventLoopGroup.next()
    }
    
    public func syncShutdown() throws {
        try client.syncShutdown()
    }
    
}


extension HTTPClient.Response {
    
    mutating func data() -> Data? {
        guard var byteBuffer = body else {
            return nil
        }
        guard let data = byteBuffer.readBytes(length: byteBuffer.readableBytes) else {
            return nil
        }
        return Data(data)
    }
    
}


extension VMWareRest {
    
    fileprivate func req(_ method: HTTPMethod, _ path: String, _ body: HTTPClient.Body? = nil) throws -> HTTPClient.Request {
        let url = config.url(for: path)
        var headers = self.headers
        if body != nil {
            headers.add(name: "Content-Type", value: "application/vnd.vmware.vmw.rest-v1+json")
        }
        let req = try HTTPClient.Request(
            url: url,
            method: method,
            headers: headers,
            body: body
        )
        return req
    }
    
    /// Retrieve data from vmrest API and turn them into a model
    public func get<C>(path: String) throws -> EventLoopFuture<C> where C: Decodable {
        let r = try req(.GET, path)
        let future = client.execute(request: r)
        return future.flatMap() { response in
            var response = response
            guard response.status == .ok else {
                return self.eventLoop.makeFailedFuture(Error.fileNotFound(path))
            }
            do {
                guard let data = response.data() else {
                    return self.eventLoop.makeFailedFuture(Error.invalidContent)
                }
                let decoded = try JSONDecoder().decode(C.self, from: data)
                return self.eventLoop.makeSucceededFuture(decoded)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    /// Post
    public func post<C, E>(path: String, post: E) throws -> EventLoopFuture<C?> where C: Decodable, E: Encodable {
        let jsonData = try JSONEncoder().encode(post)
        let body: HTTPClient.Body? = .data(jsonData)
        return try send(method: .POST, path: path, post: body)
    }
    
    /// Put
    public func put<C, E>(path: String, post: E) throws -> EventLoopFuture<C?> where C: Decodable, E: Encodable {
        let jsonData = try JSONEncoder().encode(post)
        let body: HTTPClient.Body? = .data(jsonData)
        return try send(method: .PUT, path: path, post: body)
    }
    
    /// Put
    public func put<C, S>(path: String, plain: S) throws -> EventLoopFuture<C?> where C: Decodable, S: LosslessStringConvertible {
        let body: HTTPClient.Body? = .string(String(plain))
        return try send(method: .PUT, path: path, post: body)
    }
    
    /// Delete
    public func delete(path: String) throws -> EventLoopFuture<Void> {
        let r = try req(.GET, path)
        let future = client.execute(request: r)
        return future.flatMap() { response in
            guard response.status == .ok || response.status == .noContent else {
                return self.eventLoop.makeFailedFuture(Error.fileNotFound(path))
            }
            return self.eventLoop.makeSucceededFuture(Void())
        }
    }
    
}


extension VMWareRest {
    
    /// Auth headers for request
    private var headers: HTTPHeaders {
        let loginString = "\(config.username):\(config.password)"
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        let headers: HTTPHeaders = [
            "Authorization": "Basic \(base64LoginString)",
            "Accept": "application/vnd.vmware.vmw.rest-v1+json"
        ]
        return headers
    }
    
    private func send<C>(method: HTTPMethod, path: String, post body: HTTPClient.Body? = nil) throws -> EventLoopFuture<C?> where C: Decodable {
        let r = try req(method, path, body)
        let future = client.execute(request: r)
        return future.flatMap() { response in
            var response = response
            guard response.status == .ok || response.status == .created else {
                if let data = response.data() {
                    print("Error data: " + (String(data: data, encoding: .utf8) ?? "No error data to print"))
                }
                return self.eventLoop.makeFailedFuture(Error.fileNotFound(path))
            }
            if response.body?.capacity == 0 {
                return self.eventLoop.makeSucceededFuture(nil)
            }
            do {
                guard let data = response.data() else {
                    return self.eventLoop.makeFailedFuture(Error.invalidContent)
                }
                let decoded = try JSONDecoder().decode(C.self, from: data)
                return self.eventLoop.makeSucceededFuture(decoded)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
}


extension String: VMWareRestServerConvertible {
    
    /// Self value of a string
    public var value: String {
        return self
    }
    
}


extension VMWareRest.Config {
    
    /// Build URL from a path
    func url(for path: String) -> String {
        return server.value
            .trimmingCharacters(in: .init(charactersIn: "/"))
            .appending("/")
            .appending(path)
    }
    
}
