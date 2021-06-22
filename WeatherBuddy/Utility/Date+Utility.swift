//
//  Date+Utility.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/21/21.
//

import Foundation

extension Date {
    
    func dayOfWeek(timezoneIdentifier: String? = nil) -> String? {
        let dateFormatter = DateFormatter()
        if let timezoneIdentifier = timezoneIdentifier {
            dateFormatter.timeZone = TimeZone(identifier: timezoneIdentifier)
        }
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func formattedDate(timezoneIdentifier: String? = nil) -> String? {
        let dateFormatter = DateFormatter()
        if let timezoneIdentifier = timezoneIdentifier {
            dateFormatter.timeZone = TimeZone(identifier: timezoneIdentifier)
        }
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
}
