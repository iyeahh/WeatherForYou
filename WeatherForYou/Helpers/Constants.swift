//
//  Constants.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import Foundation

struct NetworkConfig {
    static let baseURL = "https://api.openweathermap.org/data/2.5"

    enum URLPath: String {
        case weather
        case forecast
    }
}
