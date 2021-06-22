//
//  WeatherFeed.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct WeatherFeed: Codable {
    let latitude: Double?
    let longitude: Double?
    let timezone: String?
    let timezoneOffset: Int?
    let daily: [DailySnapshot]?
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case timezone
        case timezoneOffset = "timezone_offset"
        case daily
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
        timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
        timezoneOffset = try values.decodeIfPresent(Int.self, forKey: .timezoneOffset)
        daily = try values.decodeIfPresent([DailySnapshot].self, forKey: .daily)
    }
}

extension WeatherFeed {
    
    var coordinate: Coordinate? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return Coordinate(latitude: latitude, longitude: longitude)
    }
}
