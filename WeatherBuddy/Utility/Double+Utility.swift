//
//  Double+Utility.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/21/21.
//

import Foundation

extension Double {
    
    func formattedTemperature(unit: UnitTemperature = .fahrenheit) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        let measurement = Measurement(value: self, unit: unit)
        return formatter.string(from: measurement)
    }
}
