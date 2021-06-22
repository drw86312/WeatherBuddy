//
//  WeatherFeedViewModel.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/20/21.
//

import Foundation
import CoreLocation

protocol WeatherFeedViewModelDelegate: AnyObject {
    func didUpdateCellModels(models: [DailySnapshot])
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
}

class WeatherFeedViewModel: NSObject {
    
    // ViewModel delegate
    weak var delegate: WeatherFeedViewModelDelegate?
    
    // User Defaults
    private let userDefaults = UserDefaults.standard
    
    // Location
    private let geocoder = CLGeocoder()
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    private var coordinate: Coordinate? {
        get {
            guard userDefaults.object(forKey: "latitude") != nil &&
                    userDefaults.object(forKey: "longitude") != nil else {
                return nil
            }
            return Coordinate(latitude: userDefaults.double(forKey: "latitude"),
                              longitude: userDefaults.double(forKey: "longitude"))
        }
    }
}

// MARK: Public
extension WeatherFeedViewModel {
    
    func updatePage(index: Int) {
        delegate?.didUpdatePage(currentPage: index)
    }
    
    func updateLocation() {
        updateLocation(with: locationManager.authorizationStatus)
    }
    
    func reloadData() {
        guard let coordinate = coordinate else { return }
        getLocationName(coordinate)
        getFeed(coordinate)
    }
}

// MARK: Private
private extension WeatherFeedViewModel {
    
    func getFeed(_ coordinate: Coordinate) {
        
        delegate?.didUpdateLoading(isLoading: true)
        
        WeatherService.feed(coordinate: coordinate) { [weak self] result in
            DispatchQueue.main.async {
                self?.delegate?.didUpdateLoading(isLoading: false)
                switch result {
                case .success(let feed):
                    let models = feed.daily ?? []
                    self?.delegate?.didUpdateCellModels(models: models)
                    let footerModel = WeatherFeedFooterViewModel(numberOfPages: models.count)
                    self?.delegate?.didUpdateFooterModel(model: footerModel)
                case .failure(let error):
                    self?.delegate?.didError(error: error)
                }
            }
        }
    }
    
    // Get City/Locale name from Coordinate
    func getLocationName(_ coordinate: Coordinate) {
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
    
    func updateCoordinate(_ coordinate: Coordinate) {
        cacheCoordinate(coordinate)
        reloadData()
    }
    
    func cacheCoordinate(_ coordinate: Coordinate) {
        userDefaults.setValue(coordinate.latitude, forKey: "latitude")
        userDefaults.setValue(coordinate.longitude, forKey: "longitude")
    }
    
    func updateLocation(with status: CLAuthorizationStatus) {
        switch status {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined, .denied, .restricted:
            // In production, I might show additional prompt here to further request location permissions
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
        updateCoordinate(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didError(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocation(with: status)
    }
}
