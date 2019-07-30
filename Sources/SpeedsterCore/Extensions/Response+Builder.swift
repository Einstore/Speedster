import Foundation
import Fluent
import Yams


public struct ResponseMakeProperty {
    
    public static func yaml<C>(_ object: C, status: HTTPResponseStatus = .ok, headers: HTTPHeaders = [:]) throws -> Response where C: Codable {
        let yamlData = try YAMLEncoder().encode(object)
        var headers = headers
        headers.add(name: .contentType, value: "text/yaml")
        return Response(
            status: status,
            headers: headers,
            body: Response.Body(data: yamlData.data(using: .utf8) ?? Data())
        )
    }
    
    public static func deleted(headers: HTTPHeaders = [:]) -> Response {
        return Response(
            status: .noContent,
            headers: headers,
            body: Response.Body()
        )
    }
    
    public static func noContent(headers: HTTPHeaders = [:]) -> Response {
        return Response(
            status: .noContent,
            headers: headers,
            body: Response.Body()
        )
    }
    
    public static func created<C, M>(_ object: C, headers: HTTPHeaders = [:], on req: Request) -> EventLoopFuture<Response> where C: Row<M>, M: Model {
        return object.encodeResponse(status: .created, for: req)
    }
    
    public static func created<C>(_ object: C, headers: HTTPHeaders = [:], on req: Request) -> Response where C: Codable {
        return Response(status: .created, headers: headers, body: object.asBody())
    }
    
}


extension Response {
    
    public static var make: ResponseMakeProperty.Type {
        return ResponseMakeProperty.self
    }
    
    public func asSucceededFuture(on eventLoop: EventLoop) -> EventLoopFuture<Response> {
        return eventLoop.makeSucceededFuture(self)
    }
    
    public func asSucceededFuture(on req: Request) -> EventLoopFuture<Response> {
        return asSucceededFuture(on: req.eventLoop)
    }
    
}


extension Encodable {
    
    public func asResponse(_ status: HTTPResponseStatus = .ok, headers: HTTPHeaders = [:]) -> Response {
        var headers = headers
        headers.add(name: .contentType, value: "application/json; charset=utf-8")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        return Response(status: status, headers: headers, body: Response.Body(data: data ?? Data()))
    }
    
}
