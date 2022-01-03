//
//  Model.swift
//  WeatherApp
//
//  Created by barış çelik on 23.12.2021.
//

import Foundation

struct WeatherResponse: Codable {
    let hours: [Hours]
}

struct Hours: Codable {
    let airTemperature: AirTemp
    let time: String
}

struct AirTemp: Codable {
    let noaa: Double
}

struct WeatherViewModel: Codable {
    let airTemp: String
    let time: String
    let dayTime: DayTime
}

enum DayTime: Codable {
    case day
    case night
}
