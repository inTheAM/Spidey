//
//  Endpoint.swift
//  
//
//  Created by Ahmed Mgua on 20/05/2022.
//

import Foundation

/// An endpoint for a resource.
public struct Endpoint {
    
    /// The http method associated with the endpoint.
    let httpMethod: HTTPMethod
    
    /// The path to the resource.
    let url: String
    
    /// The query items to add to the endpoint when constructing the url.
    let queryItems: [URLQueryItem]
    
    public init(httpMethod: HTTPMethod, url: String, queryItems: [URLQueryItem] = []) {
        self.httpMethod = httpMethod
        self.url = url
        self.queryItems = queryItems
    }
}

