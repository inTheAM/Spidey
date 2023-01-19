//
//  NetworkManagerProtocol.swift
//
//
//  Created by Ahmed Mgua on 20/05/2022.
//

import Combine
import Foundation

public protocol NetworkManagerProtocol {
    
    // MARK: - Request with payload & Response
    
    /// Performs a request using the given endpoint, authorization type, and payload.
    /// - Parameters:
    ///   - endpoint: The endpoint for the resource being requested.
    ///   - authType: The authorization type required to access the resource being requested.
    ///   - payload: The data being sent in the request.
    /// - Returns: A publisher that publishes either the decoded response from the server or a request error.
    func performRequest<Payload, Response>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) -> AnyPublisher<Response, RequestError>
    where Payload: Encodable, Response: Decodable
    
    func performRequest<Payload, Response>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload,
        response: Response.Type) async throws -> Response
    where Payload: Encodable, Response: Decodable
    
    // MARK: - Request with no payload
    /// Performs a request using the given endpoint, authorization type, without any payload.
    ///
    /// Use this for requests that do not contain any data to send.
    /// - Parameters:
    ///   - endpoint: The endpoint for the resource being requested.
    ///   - authType: The authorization type required to access the resource being requested.
    ///   - response: The type of data expected back from the server.
    /// - Returns: A publisher that publishes either the decoded response from the server or a request error.
    func performRequest<Response>(
        endpoint: Endpoint,
        authType: AuthType,
        response: Response.Type?) -> AnyPublisher<Response, RequestError>
    where Response: Decodable
    
    
    
    // MARK: - Request with no payload, no response
    /// Performs a request using the given endpoint, authorization type, without any payload.
    ///
    /// Use this for requests that do not contain any data to send.
    /// - Parameters:
    ///   - endpoint: The endpoint for the resource being requested.
    ///   - authType: The authorization type required to access the resource being requested.
    /// - Returns: A publisher that publishes either the success state from the server or a request error.
    func performRequest(
        endpoint: Endpoint,
        authType: AuthType) -> AnyPublisher<HTTPURLResponse?, RequestError>
    
    func performRequest(
        endpoint: Endpoint,
        authType: AuthType) async throws -> HTTPURLResponse?
    
    
    
    // MARK: - Request with payload, no response
    
    func performRequest<Payload>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) -> AnyPublisher<HTTPURLResponse?, RequestError>
    where Payload: Encodable
    
    func performRequest<Payload>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) async throws -> HTTPURLResponse
    where Payload: Encodable
}
