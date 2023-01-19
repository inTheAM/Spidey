//
//  NetworkManager.swift
//  
//
//  Created by Ahmed Mgua on 20/05/2022.
//

import Combine
import Foundation

/// The main network manager for performing network calls.
public struct NetworkManager {
    
    /// The URLSession instance to use in the requests.
    internal let urlSession: URLSession
    
    internal init(session: URLSession = .shared) {
        self.urlSession = session
    }
    public init() {
        self.urlSession = URLSession.shared
    }
    
    /// Creates a `URL` from the parameters of an endpoint.
    /// Throws a `URLError.badURL` error if the url could not be created.
    /// - Returns: A URL.
    private func makeURL(from endpoint: Endpoint) throws -> URL {
        guard var components = URLComponents(string: endpoint.url)
        else { throw RequestError.invalidURL }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url
        else { throw RequestError.invalidURL }
        
        return url
    }
    
    /// Creates a `URLRequest` from the given endpoint.
    /// - Parameters:
    ///   - endpoint: The endpoint for the resource required
    /// - Returns: A URLRequest.
    private func makeURLRequest(for endpoint: Endpoint) throws -> URLRequest {
        let url = try makeURL(from: endpoint)
        var request = URLRequest(url: url, timeoutInterval: .infinity)
        request.httpMethod  =   endpoint.httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        return request
    }
    
    /// Attaches a payload to a URLRequest.
    /// - Parameters:
    ///   - payload: The data to attach to the body of the request.
    ///   - request: The request to attach the payload to.
    private func attach<Payload>(_ payload: Payload, to request: inout URLRequest) throws
    where Payload: Encodable {
        let body = try JSONEncoder().encode(payload)
        request.httpBody = body
    }
    
    /// Adds authorization headers to a request.
    /// - Parameters:
    ///   - request: The request to authorize.
    ///   - authType: The type of authorization to use.
    private func authorize(_ request: inout URLRequest, with authType: AuthType) throws {
        switch authType {
        case .none:
            break
        case .basic(let value):
            request.setValue("Basic \(value)", forHTTPHeaderField: "Authorization")
        case .bearer(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

extension NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Request with payload & Response
    
    public func performRequest<Payload, Response>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload,
        response: Response.Type) async throws -> Response
    where Payload: Encodable, Response: Decodable {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            try attach(payload, to: &request)
            let (data, _) = try await urlSession.data(for: request)
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded
        } catch {
            throw RequestError.failed(reason: error.localizedDescription)
        }
    }
    
    public func performRequest<Payload, Response>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) -> AnyPublisher<Response, RequestError>
    where Payload: Encodable, Response: Decodable {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            try attach(payload, to: &request)
            dump(request)
            let decoder = JSONDecoder()
            return urlSession.dataTaskPublisher(for: request)
#if DEBUG
                .map { output in
                    if let object = try? JSONSerialization.jsonObject(with: output.data),
                       let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                       let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        print("\n==========DATA==========\n", prettyPrintedString as Any, "\n\n")
                    }
                    return output.data
                }
#else
                .map(\.data)
#endif
                .decode(type: Response.self, decoder: decoder)
                .mapError { error in
                    dump(error, name: "ERROR LOADING DATA: ")
                    return RequestError.failedToDecodeData
                }
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: RequestError.failed(reason: error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Request with no payload
    
    func performRequest<Response>(
        endpoint: Endpoint,
        authType: AuthType,
        response: Response.Type?) async throws -> Response
    where Response: Decodable {
        var request = try makeURLRequest(for: endpoint)
        try authorize(&request, with: authType)
        let (data, _) = try await urlSession.data(for: request)
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded
    }
    
    
    public func performRequest<Response>(
        endpoint: Endpoint,
        authType: AuthType,
        response: Response.Type?) -> AnyPublisher<Response, RequestError>
    where Response: Decodable {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            dump(request)
            
            let decoder = JSONDecoder()
            return urlSession.dataTaskPublisher(for: request)
#if DEBUG
                .map { output in
                    dump(output)
                    if let object = try? JSONSerialization.jsonObject(with: output.data),
                       let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                       let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        print("\n==========DATA==========\n", prettyPrintedString as Any, "\n\n")
                    }
                    return output.data
                }
#else
                .map(\.data)
#endif
                .decode(type: Response.self, decoder: decoder)
                .mapError({ error in
                    dump(error, name: "ERROR LOADING DATA: ")
                    return RequestError.failedToDecodeData
                })
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: RequestError.failed(reason: error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Request with no payload, no response
    
    public func performRequest(
        endpoint: Endpoint,
        authType: AuthType) async throws -> HTTPURLResponse? {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            let data = try await urlSession.data(for: request)
            return data.1 as? HTTPURLResponse
        } catch {
            throw RequestError.failed(reason: error.localizedDescription)
        }
    }
    
    public func performRequest(
        endpoint: Endpoint,
        authType: AuthType) -> AnyPublisher<HTTPURLResponse?, RequestError> {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            dump(request)
            
            return urlSession.dataTaskPublisher(for: request)
#if DEBUG
                .map { output in
                    dump(output)
                    return output.response as? HTTPURLResponse
                }
#else
                .map { output in
                    return output.response as? HTTPURLResponse
                }
                
#endif
                .mapError({ error in
                    dump(error, name: "ERROR LOADING DATA: ")
                    return RequestError.failedToDecodeData
                })
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: RequestError.failed(reason: error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Request with payload, no response
    
    public func performRequest<Payload>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) async throws -> HTTPURLResponse
    where Payload: Encodable {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            try attach(payload, to: &request)
            let data = try await urlSession.data(for: request)
            
            return data.1 as! HTTPURLResponse
        } catch {
            throw RequestError.failed(reason: error.localizedDescription)
        }
    }
    
    public func performRequest<Payload>(
        endpoint: Endpoint,
        authType: AuthType,
        payload: Payload) -> AnyPublisher<HTTPURLResponse?, RequestError>
    where Payload: Encodable {
        do {
            var request = try makeURLRequest(for: endpoint)
            try authorize(&request, with: authType)
            try attach(payload, to: &request)
            dump(request)
            return urlSession.dataTaskPublisher(for: request)
#if DEBUG
                .map { output in
                    dump(output)
                    return output.response as? HTTPURLResponse
                }
#else
                .map { output in
                    return output.response as? HTTPURLResponse
                }
            
#endif
                .mapError({ error in
                    dump(error, name: "ERROR LOADING DATA: ")
                    return RequestError.failedToDecodeData
                })
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: RequestError.failed(reason: error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }
}
