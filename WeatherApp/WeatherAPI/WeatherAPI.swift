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
    
    struct Constants {
        static let apiKey = "0071f670-6402-11ec-81ce-0242ac130002-0071f6e8-6402-11ec-81ce-0242ac130002"
        static let baseUrl = "https://api.stormglass.io/v2/weather/point?"
        static let airTemperatureString = "params=airTemperature"
        static let headerParam = "Authorization"
    }
    
    func fetchData(latitude: Double,
                   longitude: Double,
                   completion: @escaping ((WeatherResponse?) -> Void)) {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        let startDate = isoDateFormatter.string(from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let endTime = dateFormatter.date(from: "\(String.rawDateFormat()) 23:00") else {
            return
        }
        let endDate = isoDateFormatter.string(from: endTime)
            
        let urlString = Constants.baseUrl + "lat=\(latitude)&" + "lng=\(longitude)&" + "start=\(startDate)&"
                        + "end=\(endDate)&" + Constants.airTemperatureString
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.addValue(Constants.apiKey, forHTTPHeaderField: Constants.headerParam)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    print(result)
//                    let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
//                    completion(response)
                    UserDefaults.standard.set(true, forKey: String.rawDateFormat())
                } catch {
                    print(error.localizedDescription)
                    completion(nil)
                }

            }
            task.resume()
        }
    }
}
