//
//  WeekWeatherRainAndImage.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/14/23.
//

import Foundation

struct WeekWeatherRainAndImage: Codable {
    let response: ImageResponse?
}

struct ImageResponse: Codable {
    let weekWeatherImageResponse: WeekWeatherImageResponse?

    enum CodingKeys: String, CodingKey {
        case weekWeatherImageResponse = "body"
    }
}

struct WeekWeatherImageResponse: Codable {
    let weekWeatherImageItems: WeekWeatherImageItems?

    enum CodingKeys: String, CodingKey {
        case weekWeatherImageItems = "items"
    }
}

struct WeekWeatherImageItems: Codable {
    let weekWeatherRainAndImageList: [WeekWeatherRainAndImageData]?

    enum CodingKeys: String, CodingKey {
        case weekWeatherRainAndImageList = "item"
    }
}

struct WeekWeatherRainAndImageData: Codable {
    let later3DaysRain, later4DaysRain: Int?
    let later5DaysRain, later6DaysRain: Int?
    let later7DaysRain, later8DaysRain: Int?
    let later9DaysRain, later10DaysRain: Int?
    
    let later3DaysWeather, later4DaysWeather: String?
    let later5DaysWeather, later6DaysWeather: String?
    let later7DaysWeather, later8DaysWeather: String?
    let later9DaysWeather, later10DaysWeather: String?

    enum CodingKeys: String, CodingKey {
        case later3DaysRain = "rnSt3Am"
        case later4DaysRain = "rnSt4Am"
        case later5DaysRain = "rnSt5Am"
        case later6DaysRain = "rnSt6Am"
        case later7DaysRain = "rnSt7Am"
        case later8DaysRain = "rnSt8"
        case later9DaysRain = "rnSt9"
        case later10DaysRain = "rnSt10"

        case later3DaysWeather = "wf3Am"
        case later4DaysWeather = "wf4Am"
        case later5DaysWeather = "wf5Am"
        case later6DaysWeather = "wf6Am"
        case later7DaysWeather = "wf7Am"
        case later8DaysWeather = "wf8"
        case later9DaysWeather = "wf9"
        case later10DaysWeather = "wf10"
    }
}
