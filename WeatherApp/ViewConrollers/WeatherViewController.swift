//
//  WeatherViewController.swift
//  Example
//
//  Created by barış çelik on 3.12.2021.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "sun.max"))
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        view.tintColor = .white
        return view
    }()
    
    private let locationManager = CLLocationManager()
    private var currentLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackGround()
        navigationController?.navigationBar.tintColor = .white
        view.addSubview(imageView)
        imageView.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }

    private func setGradientBackGround() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - Location
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    private func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        
        WeatherAPI.shared.fetchData(latitude: latitude, longitude: longitude) { response in
            guard let response = response else {
                return
            }
            
            
        }
    }
}
