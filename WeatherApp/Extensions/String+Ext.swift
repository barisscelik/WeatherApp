//
//  String+Ext.swift
//  WeatherApp
//
//  Created by barış çelik on 27.12.2021.
//

import Foundation

extension String {
    static func rawDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
