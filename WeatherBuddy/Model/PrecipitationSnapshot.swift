//
//  PrecipitationSnapshot.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation

struct PrecipitationSnapshot: Codable {
    let time: Int?
    let precipitation: Double?
    
    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case precipitation
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
        precipitation = try values.decodeIfPresent(Double.self, forKey: .precipitation)
    }
}
