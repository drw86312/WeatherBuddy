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
    var temperatureTitle: String? { get }
}

class WeatherFeedCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with model: WeatherFeedCellDisplayable?) {
        dayLabel.text = model?.dayTitle
        temperatureLabel.text = model?.temperatureTitle
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
    
    var temperatureTitle: String? {
        return temperature?.day?.formattedTemperature()
    }
}
