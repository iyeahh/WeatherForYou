//
//  TodayWeather.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/2/23.
//

import UIKit

struct TodayWeather {
    let tempMin: Double
    let tempMax: Double
    var image = UIImage(named: "think3.001")
    let temperature: Double

    init(tempMin: Double, tempMax: Double, temperature: Double) {
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.temperature = temperature
    }
}
