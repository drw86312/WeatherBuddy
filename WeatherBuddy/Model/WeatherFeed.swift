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
    let current: CurrentSnapshot?
    let minutely: [PrecipitationSnapshot]?
    let hourly: [HourlySnapshot]?
    let daily: [DailySnapshot]?
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case timezone
        case timezoneOffset = "timezone_offset"
        case current
        case minutely
        case hourly
        case daily
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
        timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
        timezoneOffset = try values.decodeIfPresent(Int.self, forKey: .timezoneOffset)
        current = try values.decodeIfPresent(CurrentSnapshot.self, forKey: .current)
        minutely = try values.decodeIfPresent([PrecipitationSnapshot].self, forKey: .minutely)
        hourly = try values.decodeIfPresent([HourlySnapshot].self, forKey: .hourly)
        daily = try values.decodeIfPresent([DailySnapshot].self, forKey: .daily)
    }
}

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

extension WeatherFeed {
    
    var coordinate: Coordinate? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return Coordinate(latitude: latitude, longitude: longitude)
    }
}
