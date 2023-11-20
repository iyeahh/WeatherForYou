//
//  WeekWeather.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/9/23.
//

import Foundation

struct WeekWeather: Codable {
    let response: Response?
}

struct Response: Codable {
    let weekWeatherResponse: WeekWeatherResponse?

    enum CodingKeys: String, CodingKey {
        case weekWeatherResponse = "body"
    }
}

struct WeekWeatherResponse: Codable {
    let weekWeatherItems: WeekWeatherItem?

    enum CodingKeys: String, CodingKey {
        case weekWeatherItems = "items"
    }
}

struct WeekWeatherItem: Codable {
    let weekWeatherTempList: [WeekWeatherTemp]?

    enum CodingKeys: String, CodingKey {
        case weekWeatherTempList = "item"
    }
}

struct WeekWeatherTemp: Codable {
    let later3DaysMinTemp, later3DaysMaxTemp: Int?
    let later4DaysMinTemp, later4DaysMaxTemp: Int?
    let later5DaysMinTemp, later5DaysMaxTemp: Int?
    let later6DaysMinTemp, later6DaysMaxTemp: Int?
    let later7DaysMinTemp, later7DaysMaxTemp: Int?
    let later8DaysMinTemp, later8DaysMaxTemp: Int?
    let later9DaysMinTemp, later9DaysMaxTemp: Int?
    let later10DaysMinTemp, later10DaysMaxTemp: Int?

    enum CodingKeys: String, CodingKey {
        case later3DaysMinTemp = "taMin3"
        case later3DaysMaxTemp = "taMax3"
        case later4DaysMinTemp = "taMin4"
        case later4DaysMaxTemp = "taMax4"
        case later5DaysMinTemp = "taMin5"
        case later5DaysMaxTemp = "taMax5"
        case later6DaysMinTemp = "taMin6"
        case later6DaysMaxTemp = "taMax6"
        case later7DaysMinTemp = "taMin7"
        case later7DaysMaxTemp = "taMax7"
        case later8DaysMinTemp = "taMin8"
        case later8DaysMaxTemp = "taMax8"
        case later9DaysMinTemp = "taMin9"
        case later9DaysMaxTemp = "taMax9"
        case later10DaysMinTemp = "taMin10"
        case later10DaysMaxTemp = "taMax10"
    }
}
