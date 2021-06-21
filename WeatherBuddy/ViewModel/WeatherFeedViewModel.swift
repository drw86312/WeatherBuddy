//
//  WeatherFeedViewModel.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation
import CoreLocation

protocol WeatherFeedViewModelDelegate: AnyObject {
    func didUpdateCellModels(models: [WeatherFeedCellDisplayable])
    func didUpdateHeaderModel(model: WeatherFeedHeaderViewModel)
    func didUpdateFooterModel(model: WeatherFeedFooterViewModel)
    func didUpdatePage(currentPage: Int)
    func didUpdateLoading(isLoading: Bool)
    func didError(error: Error)
}

struct WeatherFeedHeaderViewModel {
    let city: String?
}

struct WeatherFeedFooterViewModel {
    let numberOfPages: Int
    let currentPage: Int
}

class WeatherFeedViewModel: NSObject {
    
    private let geocoder = CLGeocoder()
    let pageTitle = Strings.pageTitle
    weak var delegate: WeatherFeedViewModelDelegate?
    private var currentCoordinate: Coordinate?
    private  var currentPage: Int = 0
    
    var isLoading: Bool = false {
        didSet {
            delegate?.didUpdateLoading(isLoading: isLoading)
        }
    }
    
    /*
     NOTE: In a larger app, I would probably put
     CoreLocation logic in a LocationManager class so
     it could be managed across the app.
     */
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
}

extension WeatherFeedViewModel {
    
    func updatePage(index: Int) {
        if index != currentPage {
            currentPage = index
            delegate?.didUpdatePage(currentPage: currentPage)
        }
    }
    
    func updateCoordinate(_ coordinate: Coordinate) {
        currentCoordinate = coordinate
        fetchData()
    }
    
    func fetchData() {
        guard let coordinate = currentCoordinate else { return }
        isLoading = true
        WeatherService.feed(coordinate: coordinate) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let feed):
                    let models = feed.daily ?? []
                    self?.delegate?.didUpdateCellModels(models: models)
                    let footerModel = WeatherFeedFooterViewModel(numberOfPages: models.count,
                                                                 currentPage: self?.currentPage ?? 0)
                    self?.delegate?.didUpdateFooterModel(model: footerModel)
                case .failure(let error):
                    self?.delegate?.didError(error: error)
                }
            }
        }
    }
    
    func getLocationName(for coordinate: Coordinate) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let headerModel = WeatherFeedHeaderViewModel(city: placemark.locality)
                    self?.delegate?.didUpdateHeaderModel(model: headerModel)
                    return
                }
            }
        }
    }
    
    func updateLocation() {
        updateLocation(with: locationManager.authorizationStatus)
    }
    
    func cacheCoordinate(_ coordinate: Coordinate) {
        let defaults = UserDefaults.standard
        defaults.setValue(coordinate.latitude, forKey: "latitude")
        defaults.setValue(coordinate.longitude, forKey: "longitude")
    }
    
    func retrieveCachedCoordinate() -> Coordinate? {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: "latitude") != nil && defaults.object(forKey: "longitude") != nil else {
            return nil
        }
        return Coordinate(latitude: defaults.double(forKey: "latitude"),
                          longitude: defaults.double(forKey: "longitude"))
    }
    
    private func updateLocation(with status: CLAuthorizationStatus) {
        switch status {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined, .denied, .restricted:
            // Production might show additional prompt here to allow location permissions
            return
        @unknown default:
            return
        }
    }
}

extension WeatherFeedViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.first else { return }
        let coordinate = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        getLocationName(for: coordinate)
        updateCoordinate(coordinate)
        cacheCoordinate(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didError(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocation(with: status)
    }
}

extension WeatherFeedViewModel {
    struct Strings {
        static let pageTitle = NSLocalizedString("Weather Buddy", comment: "Title for weather feed view controller")
    }
}
