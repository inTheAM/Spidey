//
//  HTTPMethod.swift
//  
//
//  Created by Ahmed Mgua on 20/05/2022.
//

import Foundation

/// The HTTPMethod of an Endpoint
public enum HTTPMethod: String {
    case get = "GET",
         post = "POST",
         put = "PUT",
         delete = "DELETE",
         webSocket
}
