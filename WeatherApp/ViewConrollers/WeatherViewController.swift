//
//  WeatherViewController.swift
//  Example
//
//  Created by barış çelik on 3.12.2021.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    private let degreeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
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
        collection.layer.masksToBounds = true
        return collection
    }()
    
    let gradient = CAGradientLayer()
    
    private let locationManager = CLLocationManager()
    private var currentLocation : CLLocation?
    
    var models = [WeatherViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        setGradientBackGround()
        view.addSubview(imageView)
        imageView.center = view.center
        view.addSubview(degreeLabel)
        degreeLabel.center = view.center
        view.addSubview(dateLabel)
        dateLabel.center = view.center
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
        let labelSize: CGFloat = 100
        degreeLabel.frame = CGRect(x: (view.frame.size.width - labelSize) / 2,
                                   y: view.safeAreaInsets.bottom + 10,
                                   width: labelSize, height: labelSize)
        dateLabel.frame = CGRect(x: (view.frame.size.width - labelSize) / 2,
                                 y: view.safeAreaInsets.bottom + 20 + labelSize,
                                 width: labelSize, height: labelSize)
        imageView.frame = CGRect(x: (view.frame.size.width - imageSize) / 2,
                                 y: view.safeAreaInsets.bottom + 30 + 2 * labelSize,
                                 width: imageSize,
                                 height: imageSize)
        weatherCollectionView.frame = CGRect(x: 0,
                                             y: (view.frame.size.height) - 300.0,
                                             width: view.frame.size.width,
                                             height: 220)
    }

    private func setGradientBackGround() {
        gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]
        gradient.locations = [0.0, 0.7]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
    }
    
    private func setWeatherType(degree: Int, dayTime: DayTime) -> WeatherType {
        
        if degree <= 0 {
            return .snow
        }
        else if degree <= 5 {
            return .rainy
        }
        else if degree <= 10 {
            return .cloudy
        }
        else if degree <= 15 {
            return dayTime != .night ? .cloudysun : .cloudymoon
        }
        else {
            return dayTime != .night ? .sunny : .clear
        }

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
                
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                let seperatorTimeNight = formatter.date(from: "\(String.rawDateFormat()) 19:00") ?? Date()
                let seperatorTimeNoon = formatter.date(from: "\(String.rawDateFormat()) 14:00") ?? Date()
                
                let dayTime : DayTime = date < seperatorTimeNight ? (date < seperatorTimeNoon ? .day : .afternoon) : .night
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .none
                let number = numberFormatter.number(from: "\(data.airTemperature.noaa)") ?? 0
                let airTemp = numberFormatter.string(from: number) ?? ""
                
                guard let weatherType = self?.setWeatherType(degree: number.intValue, dayTime: dayTime) else {
                    return
                }
                
                self?.models.append(WeatherViewModel(airTemp: airTemp, time: time,
                                                     dayTime: dayTime, weatherType: weatherType))
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
        let model = models[indexPath.item]
        
        degreeLabel.text = "\(model.airTemp)° C"
        dateLabel.text = model.time
        imageView.image = UIImage(systemName: model.weatherType.rawValue)
        
        switch model.dayTime {
        case .day:
            gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]
        case .afternoon:
            gradient.colors = [UIColor.white.cgColor, UIColor.systemBlue.cgColor]
        case .night:
            gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        }
    }
}
