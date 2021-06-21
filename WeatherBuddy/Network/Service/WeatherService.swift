//
//  WeatherService.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct WeatherService {
    
    static func feed(coordinate: Coordinate, completion: @escaping ((Result<WeatherFeed, NetworkError>) -> Void)) {
        NetworkManager.request(endpoint: .feed(coordinate: coordinate),
                               modelType: WeatherFeed.self) { result in
            completion(result)
        }
    }
}
