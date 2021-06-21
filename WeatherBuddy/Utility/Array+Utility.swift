//
//  Array+Utility.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/21/21.
//

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
