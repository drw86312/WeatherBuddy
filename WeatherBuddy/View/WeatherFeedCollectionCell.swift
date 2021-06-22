//
//  WeatherFeedCollectionCell.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import UIKit

protocol WeatherFeedCellDisplayable {
    var imageURL: URL? { get }
    var dayTitle: String? { get }
    var dateTitle: String? { get }
    var temperatureTitle: String? { get }
    var highLowTitle: String? { get }
    var weatherDescription: String? { get }
}

class WeatherFeedCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var highLowLabel: UILabel!
    
    func update(with model: WeatherFeedCellDisplayable?) {
        
        // Ran out of time, but in production I would add accessibility to these views
        dayLabel.text = model?.dayTitle
        dateLabel.text = model?.dateTitle
        temperatureLabel.text = model?.temperatureTitle
        highLowLabel.text = model?.highLowTitle
        if let imageURL = model?.imageURL {
            imageView.load(url: imageURL)
        }
    }
}


extension DailySnapshot: WeatherFeedCellDisplayable {
    
    var imageURL: URL? {
        return weatherConditions?.first?.iconURL
    }
    
    var dayTitle: String? {
        return now?.dayOfWeek()
    }
    
    var dateTitle: String? {
        return  now?.formattedDate()
    }
    
    var temperatureTitle: String? {
        return temperature?.day?.formattedTemperature()
    }
    
    // Ran out of time, but in production I would localize these strings
    var highLowTitle: String? {
        var text: String = ""
        if let low = temperature?.min?.formattedTemperature() {
            let lowString = "Low: " + low
            text.append(lowString)
        }
        if let high = temperature?.max?.formattedTemperature() {
            let highString = " | High: " + high
            text.append(highString)
        }
        return text
    }
    
    var weatherDescription: String? {
        return weatherConditions?.first?.description
    }
}
