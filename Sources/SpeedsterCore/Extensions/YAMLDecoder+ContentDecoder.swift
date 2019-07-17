//
//  YAMLDecoder+ContentDecoder.swift
//  
//
//  Created by Ondrej Rafaj on 20/06/2019.
//

import Yams
import Vapor


extension YAMLDecoder: ContentDecoder {
    
    public func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPHeaders) throws -> D where D : Decodable {
        var b = body
        guard let data = b.readData(length: body.readableBytes), let string = String(data: data, encoding: .utf8) else {
            throw GenericError.decodingError(nil)
        }
        return try YAMLDecoder().decode(from: string)
    }
    
}
