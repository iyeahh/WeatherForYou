//
//  Forecast.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/6/23.
//

import Foundation


struct Forecast: Codable {
    let weatherInfoList: [WeatherInfo]?

    enum CodingKeys: String, CodingKey {
        case weatherInfoList = "list"
    }
}

struct WeatherInfo: Codable {
    let tempInfo: TempInfo?   // 주요 날씨 정보
    let weather: [ForecastWeather]?          // 날씨 상태 정보
    let dateText: String?

    enum CodingKeys: String, CodingKey {
        case weather
        case tempInfo = "main"
        case dateText = "dt_txt"
    }
}

struct TempInfo: Codable {
    let temp: Double?       // current temperature
    let feelsLike: Double?   // 체감온도
    let tempMin: Double?     // 최저
    let tempMax: Double?     // 최고

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct ForecastWeather: Codable {
    let icon: String?     // 날씨 아이콘
}

