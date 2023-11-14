//
//  Constants.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import Foundation

struct NetworkConfig {
    static let baseURL = "https://api.openweathermap.org/data/2.5"
    static let weekWeatherURL = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa?numOfRows=10&pageNo=1&dataType=JSON"
    static let weekWeatherImageURL = "http://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst?numOfRows=10&pageNo=1&dataType=JSON"

    enum URLPath: String {
        case weather
        case forecast
    }
}
