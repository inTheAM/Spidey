//
//  RequestError.swift
//  Dashboard
//
//  Created by Ahmed Mgua on 01/07/2022.
//

import Foundation

public enum RequestError: Error {
    case invalidURL
    case invalidDataFromServer
    case invalidResponseFromServer
    case failedToDecodeData
    case unauthorizedRequest
    case failedAuthorization
    case failed(reason: String)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidDataFromServer:
            return "No data from server."
        case .invalidResponseFromServer:
            return "Invalid response from server."
        case .failedToDecodeData:
            return "Unable to decode data from server."
        case .unauthorizedRequest:
            return "Unauthorized request."
        case .failedAuthorization:
            return "Failed to authorize request"
        case .failed(let reason):
            return reason
        }
    }
}
