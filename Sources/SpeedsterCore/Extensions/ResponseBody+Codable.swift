//
//  ResponseBody+Codable.swift
//  
//
//  Created by Ondrej Rafaj on 19/06/2019.
//

import Vapor


extension Encodable {
    
    public func asBody() -> Response.Body {
        let data = try! JSONEncoder().encode(self)
        return Response.Body(data: data)
    }
    
}
