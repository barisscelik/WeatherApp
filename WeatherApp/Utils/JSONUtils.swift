//
//  JSONUtils.swift
//  WeatherApp
//
//  Created by barış çelik on 3.01.2022.
//

import Foundation

final class JSONUtils {
    
    static func jsonDecoder<T: Decodable>(param: String, object: T.Type) -> T? {
        guard let data = param.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    static func jsonEncoder<T: Encodable>(data: T) -> String {
        do {
            let jsonData = try JSONEncoder().encode(data)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return "" }
            return jsonString
        } catch {
            return "{}"
        }
    }
}
