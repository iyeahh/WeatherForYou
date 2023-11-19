//
//  CurrentWeather.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import Foundation

struct CurrentWeather: Codable {
    let weather: [Weather]?
    let temp: Temperature?

    enum CodingKeys: String, CodingKey {
        case weather
        case temp = "main"
    }
}

struct Temperature: Codable {
    let temp, feelsLike, tempMin, tempMax: Double?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Weather: Codable {
    let icon: String?
}
