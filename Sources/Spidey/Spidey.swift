//
//  Spidey.swift
//  
//
//  Created by Ahmed Mgua on 24/05/23.
//

import Combine
import Foundation

public enum Spidey {
    static let networkManager = NetworkManager()

    public static func request<Payload, Response>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload,
        response: Response.Type) async throws -> Response
    where Payload: Encodable, Response: Decodable {
        try await networkManager.performRequest(endpoint: endpoint, authType: authType, payload: payload, response: response)
    }

    public static func performRequest<Payload, Response>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) -> AnyPublisher<Response, RequestError>
    where Payload: Encodable, Response: Decodable {
        networkManager.performRequest(endpoint: endpoint, authType: authType, payload: payload)
    }

    // MARK: - Request with no payload

    public static func performRequest<Response>(
        endpoint: Endpoint,
        authType: AuthType,
        response: Response.Type?) async throws -> Response
    where Response: Decodable {
        try await networkManager.performRequest(endpoint: endpoint, authType: authType, response: response)
    }


    public static func performRequest<Response>(
        endpoint: Endpoint,
        authType: AuthType,
        response: Response.Type?) -> AnyPublisher<Response, RequestError>
    where Response: Decodable {
        networkManager.performRequest(endpoint: endpoint, authType: authType, response: response)
    }

    // MARK: - Request with no payload, no response

    public static func performRequest(
        endpoint: Endpoint,
        authType: AuthType) async throws -> HTTPURLResponse? {
            try await networkManager.performRequest(endpoint: endpoint, authType: authType)
    }

    public static func performRequest(
        endpoint: Endpoint,
        authType: AuthType) -> AnyPublisher<HTTPURLResponse?, RequestError> {
            networkManager.performRequest(endpoint: endpoint, authType: authType)
    }

    // MARK: - Request with payload, no response

    public static func performRequest<Payload>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) async throws -> HTTPURLResponse
    where Payload: Encodable {
        try await networkManager.performRequest(endpoint: endpoint, authType: authType, payload: payload)
    }

    public static func performRequest<Payload>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) -> AnyPublisher<HTTPURLResponse?, RequestError>
    where Payload: Encodable {
        networkManager.performRequest(endpoint: endpoint, authType: authType, payload: payload)
    }
}
