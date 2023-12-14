//
//  TodayViewModel.swift
//  WeatherForYou
//
//  Created by Bora Yang on 12/1/23.
//

import Foundation
import UIKit

class TodayViewModel {
    let weatherDataManager = WeatherDataManager.shared

    var index: Int?

    var weather: MainWeater? {
        return weatherDataManager.mainWeater
    }

    var cityName: String {
        return weatherDataManager.cityName
    }

    var textColor: UIColor? {
        return weather?.textColor
    }

    var dateString: String? {
        return weather?.dateString
    }

    var feelsLikeTemp: String? {
        return "체감온도: \(Int(weather?.feelsLikeTemp ?? 0.0))°C"
    }

    var currentTemp: String? {
        return "\(Int(weather?.currentTemp ?? 0.0))°C"
    }

    var weatherImage: UIImage? {
        return weather?.weatherImage
    }

    var backgroundColor: (UIColor, UIColor) {
        return weather?.backgroundColor ?? (UIColor.weatherTheme.base.0, UIColor.weatherTheme.base.1)
    }

    var todayWeatherListCount: Int {
        return weatherDataManager.todayWeatherList.count
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .cityName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .mainWeather, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .todayWeatherList, object: nil)
    }

    var onDataUpdated: (() -> Void)?

    @objc private func dataManagerDidUpdateData() {
        DispatchQueue.main.async {
            self.onDataUpdated?()
        }
    }

    func validWeatherData() -> Bool {
        return  weather != nil ? true : false
    }

    func getTimeString(index: Int) -> String? {
        guard let date = weatherDataManager.todayWeatherList[index].dateText else { return "" }
        return  Date.dateToHours(date: date)
    }

    func getTempString(index: Int) -> String? {
        guard let temp = weatherDataManager.todayWeatherList[index].tempInfo?.temp else { return "" }
        let roundedTemp = round(temp)
        return "\(Int(roundedTemp))°C"
    }

    func getIconImageWithColor(index: Int) -> UIImage? {
        guard let textColor = weatherDataManager.mainWeater?.textColor else { return nil }
        guard let icon = weatherDataManager.todayWeatherList[index].weather?.first?.icon else { return nil }
        return weatherDataManager.setImage(iconString: icon)?.withTintColor(textColor)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
