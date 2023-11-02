//
//  TodayWeather.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/2/23.
//

import UIKit

struct TodayWeather {
    let date: String
    let location: String
    let skyStatus: String
    var image = UIImage(named: "think3.001")
    let temperature: String

    init(date: String, location: String, skyStatus: String, temperature: String) {
        self.date = date
        self.location = location
        self.skyStatus = skyStatus
        self.temperature = temperature
    }
}
