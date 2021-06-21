//
//  PrecipitationSnapshot.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct PrecipitationSnapshot: Codable {
    let now: Date?
    let precipitation: Double?
    
    enum CodingKeys: String, CodingKey {
        case now = "dt"
        case precipitation
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        now = try values.decodeIfPresent(Int.self, forKey: .now)?.date
        precipitation = try values.decodeIfPresent(Double.self, forKey: .precipitation)
    }
}
