//
//  DailySnapshot.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct DayValue: Codable {
    let day: Double?
    let min: Double?
    let max: Double?
    let night: Double?
    let eve: Double?
    let morn: Double?
}

struct DailySnapshot: Codable {
    let currentTime: Int?
    let sunriseTime: Int?
    let sunsetTime: Int?
    let moonriseTime: Int?
    let moonsetTime: Int?
    let temperature: DayValue?
    let feelsLike: DayValue?
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
        case currentTime = "dt"
        case sunriseTime = "sunrise"
        case sunsetTime = "sunset"
        case moonriseTime = "moonrise"
        case moonsetTime = "moonset"
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
        currentTime = try values.decodeIfPresent(Int.self, forKey: .currentTime)
        sunriseTime = try values.decodeIfPresent(Int.self, forKey: .sunriseTime)
        sunsetTime = try values.decodeIfPresent(Int.self, forKey: .sunsetTime)
        moonriseTime = try values.decodeIfPresent(Int.self, forKey: .moonriseTime)
        moonsetTime = try values.decodeIfPresent(Int.self, forKey: .moonsetTime)
        temperature = try values.decodeIfPresent(DayValue.self, forKey: .temperature)
        feelsLike = try values.decodeIfPresent(DayValue.self, forKey: .feelsLike)
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
