//
//  NetworkManager.swift
//  Weather
//
//  Created by David Warner on 6/19/21.
//

import Foundation

enum NetworkError: Error {
    case malformedURL
    case noData
    case decoding(Error)
}

struct NetworkManager {
    
    // I made URLSession a parameter for dependency injection and the
    // ability to make this function unit testable in the future.
    static func request<T: Codable>(endpoint: Endpoint,
                                     modelType: T.Type,
                                     session: URLSession = .shared,
                                     completion: @escaping ((Result<T, NetworkError>) -> Void)) {
        guard let request = endpoint.request else {
            completion(.failure(.malformedURL))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }
        
        task.resume()
    }
}
