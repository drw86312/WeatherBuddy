//
//  NetworkManager.swift
//  Weather
//
//  Created by David Warner on 6/19/21.
//

import Foundation

protocol EndpointDefinable {
    var httpMethod: HTTPMethod { get }
    var baseURLString: String { get }
    var path: String { get }
    var headers: [String: Any]? { get }
    var body: [String: Any]? { get }
}

extension EndpointDefinable {
    var url: String {
        return "https://api.openweathermap.org/data/2.5/onecall?lat=33.44&lon=-94.04&appid=cdbe8f3572c12271ea5cf142b09c6d2a"
        //return baseURLString + path
    }
}

public enum HTTPMethod : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case malformedURL
    case noData
    case decoding(Error)
}

struct WeatherService {
    
    static func getWeather() {
        let manager = NetworkManager()
        let request = manager.getThing(endpoint: .getWeather) { result in
            print("")
        }
    }
    
}


struct NetworkManager {
    let apiKey = "cdbe8f3572c12271ea5cf142b09c6d2a"
    
    func getThing(endpoint: Endpoint,
                  session: URLSession = .shared,
                  completion: @escaping ((Result<WeatherFeed, NetworkError>) -> Void)) {
        guard let url = URL(string: endpoint.url) else {
            completion(.failure(.malformedURL))
            return
        }
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let feed = try JSONDecoder().decode(WeatherFeed.self, from: data)
                completion(.success(feed))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }
        
        task.resume()
    }
}

enum Endpoint: EndpointDefinable {
    case getWeather
                
    var httpMethod: HTTPMethod {
        switch self {
        case .getWeather:
            return .get
        }
    }
    
    var baseURLString: String {
        switch self {
        case .getWeather:
            return "https://api.openweathermap.org/data/2.5/onecall"
        }
    }
    
    var path: String {
        switch self {
        case .getWeather:
            return ""
        }
    }
    
    var headers: [String: Any]? {
        switch self {
        case .getWeather:
            return ["Content-Type": "application/json"]
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .getWeather:
            return [:]
        }
    }
}
