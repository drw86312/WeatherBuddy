//
//  WeatherDetailViewController.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import UIKit

class WeatherDetailViewController: UIViewController {
    
    var model: DailySnapshot?
    @IBOutlet private weak var descriptionLabel: UILabel!

    // Ran out of time, but would provide additional weather data here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = model?.dayTitle
        descriptionLabel.text = model?.weatherDescription
    }
}
