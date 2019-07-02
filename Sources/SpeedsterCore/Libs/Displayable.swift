//
//  Displayable.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Fluent


public protocol Displayable {
    
    associatedtype Display: Codable
    
    func asDisplay() -> Display
    
}


extension Displayable {
    
    public func asDisplayResponse(_ status: HTTPResponseStatus = .ok, headers: HTTPHeaders = [:]) -> Response {
        var headers = headers
        headers.add(name: .contentType, value: "application/json;charset=utf-8")
        return Response(status: status, headers: headers, body: asDisplay().asBody())
    }
    
}


public protocol DisplayableArray {
    
    associatedtype Display: Encodable
    
    func asDisplay() -> [Display]
    
}


extension DisplayableArray {
    
    public func asDisplayResponse(_ status: HTTPResponseStatus = .ok, headers: HTTPHeaders = [:]) -> Response {
        var headers = headers
        headers.add(name: .contentType, value: "application/json;charset=utf-8")
        return Response(status: status, headers: headers, body: asDisplay().asBody())
    }
    
}


extension Array: DisplayableArray where Element: Encodable {
    
    public func asDisplay() -> [Element] {
        return self
    }
    
}

