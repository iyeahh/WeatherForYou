//
//  Forecast.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/6/23.
//

import Foundation


// MARK: - Forecast
struct Forecast: Codable {
    let cod: String?
    let message: Int?
    let cnt: Int?      // 몇개의 데이터 인지
    let weatherInfoList: [WeatherInfo]?
    let city: ForecastCity?    // 도시

    enum CodingKeys: String, CodingKey {
        case cod, message, cnt, city
        case weatherInfoList = "list"
    }
}

// MARK: - City
struct ForecastCity: Codable {
    let id: Int?
    let name: String?
    let coord: ForecastCoord?
    let country: String?
    let population, timezone, sunrise, sunset: Int?
}

// MARK: - Coord
struct ForecastCoord: Codable {
    let lat, lon: Double?
}

// MARK: - List
struct WeatherInfo: Codable {
    let dt: Int?         // UTC기준 날씨 예상 시간
    let mainInfo: MainInfo?   // 주요 날씨 정보
    let weather: [ForecastWeather]?          // 날씨 상태 정보
    let visibility: Int?
    let pop: Double?
    let rain: ForecastRain?
    let dtTxt: String?

    enum CodingKeys: String, CodingKey {
        case dt, weather, visibility, pop, rain
        case mainInfo = "main"
        case dtTxt = "dt_txt"
    }
}

// MARK: - Main
struct MainInfo: Codable {
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

// MARK: - Rain
struct ForecastRain: Codable {
    let the3H: Double?   // 3 시간 기준 강수량

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - Weather
struct ForecastWeather: Codable {
    let id: Int?      // 날씨 상태 아이디
    let main: String?     // Rain, Snow, Clouds
    let icon: String?     // 날씨 아이콘
}

