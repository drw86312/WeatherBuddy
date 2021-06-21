//
//  Int+Utility.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/21/21.
//

import Foundation

extension Int {
    
    var date: Date? {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}
