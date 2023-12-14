//
//  ThisWeekViewModel.swift
//  WeatherForYou
//
//  Created by Bora Yang on 12/1/23.
//

import Foundation
import UIKit

class ThisWeekViewModel {
    let weatherDataManager = WeatherDataManager.shared

    var cityName: String {
        weatherDataManager.cityName
    }

    var weekWeatherListCount: Int {
        weatherDataManager.weekWeatherArray.count
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .weekWeatherList, object: nil)
    }

    var onDataUpdated: (() -> Void)?

    @objc private func dataManagerDidUpdateData() {
        DispatchQueue.main.async {
            self.onDataUpdated?()
        }
    }

    func getDateString(index: Int) -> String? {
        let weekWeather = weatherDataManager.weekWeatherArray[index]
        guard let afterHours = weekWeather.afterHours else { return nil }
        return Date.dateFormatterForWeek(afterHours: afterHours)
    }

    func getTempImage(index: Int) -> UIImage? {
        let weekWeather = weatherDataManager.weekWeatherArray[index]
        guard let tempImage = weekWeather.tempImage else { return nil }
        return tempImage
    }

    func getTempString(index: Int) -> String? {
        let weekWeather = weatherDataManager.weekWeatherArray[index]
        guard let tempMax = weekWeather.tempMax,
              let tempMin = weekWeather.tempMin else { return nil }
        return "\(tempMax)°C / \(tempMin)°C"
    }

    func getRainString(index: Int) -> String? {
        let weekWeather = weatherDataManager.weekWeatherArray[index]
        guard let rain = weekWeather.rain else { return nil }
        return "\(rain)%"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
