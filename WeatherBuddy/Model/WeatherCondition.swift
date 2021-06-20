//
//  WeatherCondition.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct WeatherCondition: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        main = try values.decodeIfPresent(String.self, forKey: .main)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
    }
}
