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
        view.tintColor = .white
        return view
    }()
    
    private let weatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 220)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(WeatherCollectionViewCell.self,
                            forCellWithReuseIdentifier: WeatherCollectionViewCell.identifier)
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    let gradient = CAGradientLayer()
    
    private let locationManager = CLLocationManager()
    private var currentLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        setGradientBackGround(to: view)
        view.addSubview(imageView)
        imageView.center = view.center
        //setGradientBackGround(to: weatherCollectionView.backgroundView!)
        view.addSubview(weatherCollectionView)
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 200
        imageView.frame = CGRect(x: (view.frame.size.width - imageSize) / 2,
                                 y: view.safeAreaInsets.bottom,
                                 width: imageSize,
                                 height: imageSize)
        weatherCollectionView.frame = CGRect(x: 0,
                                             y: (view.frame.size.height) - 300.0,
                                             width: view.frame.size.width,
                                             height: 220)
    }

    private func setGradientBackGround(to view: UIView) {
        gradient.colors = [UIColor.white.cgColor, UIColor.systemBlue.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
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
            //requestWeatherForLocation()
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

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier,
                                                            for: indexPath) as? WeatherCollectionViewCell else {
            fatalError()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    }
}
