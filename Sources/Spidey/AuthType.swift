//
//  AuthType.swift
//  
//
//  Created by Ahmed Mgua on 20/05/2022.
//

import Foundation

/// The authorization requirement of an endpoint.
public enum AuthType {
    /// Basic authorization. Header is provided, fill in the value.
    case basic(value: String),
         
         /// Bearer token authentication. Header is provided, fill in the token value.
         bearer(token: String),
         
         
         none
}
