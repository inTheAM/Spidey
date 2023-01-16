//
//  Endpoint+MakeURL.swift
//  
//
//  Created by Ahmed Mgua on 20/05/2022.
//

import Foundation

extension Endpoint {
    
    /// Creates a `URL` from the parameters of an endpoint.
    /// Throws a `URLError.badURL` error if the url could not be created.
    /// - Returns: A URL.
    func makeURL() throws -> URL {
//        var components = URLComponents()
//        components.scheme = httpMethod == .webSocket ? "wss" : "https"
//        components.host = Self.baseURL
//        components.path = "/\(path)"
//        components.queryItems = queryItems
//
//        guard let url = components.url else {
//            throw RequestError.invalidURL
//        }
        
        guard let url = URL(string: self.url)
        else { throw RequestError.invalidURL }
        
        return url
    }
}
