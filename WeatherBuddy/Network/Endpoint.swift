//
//  Endpoint.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

public enum HTTPMethod : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum Endpoint {
    case feed(coordinate: Coordinate)
    
    var request: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
    
    private var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let value = NSDictionary(contentsOfFile: filePath)?.object(forKey: "API_KEY") as? String else {
                preconditionFailure("No API Key")
            }
            return value
        }
    }
    
    private var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
    
    private var scheme: String {
        switch self {
        case .feed:
            return "https"
        }
    }
    
    private var host: String {
        switch self {
        case .feed:
            return "api.openweathermap.org"
        }
    }
    
    private var path: String {
        switch self {
        case .feed:
            return "/data/2.5/onecall"
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .feed:
            return .get
        }
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .feed(let coordinate):
            return [URLQueryItem(name: "lat", value: String(coordinate.latitude)),
                    URLQueryItem(name: "lon", value: String(coordinate.longitude)),
                    URLQueryItem(name: "units", value: "imperial"),
                    URLQueryItem(name: "appid", value: apiKey)]
        }
    }
}
