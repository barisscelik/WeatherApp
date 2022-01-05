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
    let weatherType : WeatherType
}

enum DayTime: Codable {
    case day
    case afternoon
    case night
}

enum WeatherType: String, Codable {
    case sunny = "sun.max"
    case cloudy = "cloud"
    case rainy = "cloud.heavyrain"
    case snow = "snowflake"
    case cloudysun = "cloud.sun"
    case cloudymoon = "cloud.moon"
    case clear = "moon"
}
