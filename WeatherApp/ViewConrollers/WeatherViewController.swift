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
    
    var models = [WeatherViewModel]()
    
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
            requestWeatherForLocation()
        }
    }
    
    private func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        if UserDefaults.standard.bool(forKey: String.rawDateFormat()) {
            guard let viewModelString = UserDefaults.standard.string(forKey: "model"),
                  let viewModel = JSONUtils.jsonDecoder(param: viewModelString, object: [WeatherViewModel].self)  else {
                return
            }
            models = viewModel
            
            DispatchQueue.main.async { [weak self] in
                self?.weatherCollectionView.reloadData()
            }
            return
        }
        
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        
        WeatherAPI.shared.fetchData(latitude: latitude, longitude: longitude) { [weak self] response in
            guard let response = response else {
                return
            }
            let group = DispatchGroup()
            response.hours.forEach { data in
                group.enter()
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.timeZone = TimeZone(abbreviation: "GMT")
                let date = isoFormatter.date(from: data.time) ?? Date()
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(abbreviation: "UTC+03")
                formatter.locale = NSLocale.current
                formatter.dateFormat = "HH:mm"
                let time = formatter.string(from: date)
                
                let seperatorTime = formatter.date(from: "18:00") ?? Date()
                
                let dayTime : DayTime = date < seperatorTime ? .day : .night
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .none
                let number = numberFormatter.number(from: "\(data.airTemperature.noaa)") ?? 0
                let airTemp = numberFormatter.string(from: number) ?? ""
                
                self?.models.append(WeatherViewModel(airTemp: airTemp, time: time, dayTime: dayTime))
                group.leave()
            }
            
            group.notify(queue: .main) {
                let modelEncoded = JSONUtils.jsonEncoder(data: self?.models)
                UserDefaults.standard.set(modelEncoded, forKey: "model")
                self?.weatherCollectionView.reloadData()
            }
            
        }
    }
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier,
                                                            for: indexPath) as? WeatherCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    }
}
