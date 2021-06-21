//
//  CurrentSnapshot.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct CurrentSnapshot: Codable {
    let now: Date?
    let sunrise: Date?
    let sunset: Date?
    let temperature: Double?
    let feelsLike: Double?
    let pressure: Int?
    let humidity: Int?
    let dewPoint: Double?
    let uvi: Double?
    let clouds: Int?
    let visibility: Int?
    let windSpeed: Double?
    let windDirection: Int?
    let weatherConditions: [WeatherCondition]?

    enum CodingKeys: String, CodingKey {
        case now = "dt"
        case sunrise
        case sunset
        case temperature = "temp"
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case uvi
        case clouds
        case visibility
        case windSpeed = "wind_speed"
        case windDirection = "wind_deg"
        case weatherConditions = "weather"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        now = try values.decodeIfPresent(Int.self, forKey: .now)?.date
        sunrise = try values.decodeIfPresent(Int.self, forKey: .sunrise)?.date
        sunset = try values.decodeIfPresent(Int.self, forKey: .sunset)?.date
        temperature = try values.decodeIfPresent(Double.self, forKey: .temperature)
        feelsLike = try values.decodeIfPresent(Double.self, forKey: .feelsLike)
        pressure = try values.decodeIfPresent(Int.self, forKey: .pressure)
        humidity = try values.decodeIfPresent(Int.self, forKey: .humidity)
        dewPoint = try values.decodeIfPresent(Double.self, forKey: .dewPoint)
        uvi = try values.decodeIfPresent(Double.self, forKey: .uvi)
        clouds = try values.decodeIfPresent(Int.self, forKey: .clouds)
        visibility = try values.decodeIfPresent(Int.self, forKey: .visibility)
        windSpeed = try values.decodeIfPresent(Double.self, forKey: .windSpeed)
        windDirection = try values.decodeIfPresent(Int.self, forKey: .windDirection)
        weatherConditions = try values.decodeIfPresent([WeatherCondition].self, forKey: .weatherConditions)
    }
}
