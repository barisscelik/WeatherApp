//
//  WeatherAPI.swift
//  WeatherApp
//
//  Created by barış çelik on 23.12.2021.
//

import Foundation

final class WeatherAPI {
    
    static let shared = WeatherAPI()
    
    private init() {}
    
    let apiKey = "0071f670-6402-11ec-81ce-0242ac130002-0071f6e8-6402-11ec-81ce-0242ac130002"
    let baseUrl = "https://api.stormglass.io/v2/weather/point?"
    let airTemperatureString = "params=airTemperature"
    let headerParam = "Authorization"
    
    func fetchData(latitude: Double,
                   longitude: Double,
                   completion: @escaping ((WeatherResponse?) -> Void)) {
        let urlString = baseUrl + "lat=\(latitude)&" + "lng=\(longitude)&"
                                + airTemperatureString
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.addValue(apiKey, forHTTPHeaderField: headerParam)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    completion(response)
                } catch {
                    print(error.localizedDescription)
                    completion(nil)
                }

            }
            task.resume()
        }
    }
}
