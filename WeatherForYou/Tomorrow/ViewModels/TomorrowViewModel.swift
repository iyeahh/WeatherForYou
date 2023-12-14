//
//  TomorrowViewModel.swift
//  WeatherForYou
//
//  Created by Bora Yang on 12/1/23.
//

import Foundation
import UIKit

class TomorrowViewModel {
    let weatherDataManager = WeatherDataManager.shared

    var cityName: String {
        return weatherDataManager.cityName
    }

    var tomorrowDateString: String {
        return Date.tomorrowAndNextDayToString().0
    }

    var dayAfterTomorrowDateString: String {
        return Date.tomorrowAndNextDayToString().1
    }

    var tomorrowWeatherListCount: Int {
        return weatherDataManager.tomorrowWeatherList.count
    }

    var dayAfterTomorrowWeatherListCount: Int {
        return weatherDataManager.dayAfterTomorrowWeatherList.count
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .cityName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .tomorrowWeatherList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataManagerDidUpdateData), name: .dayAfterTomorrowWeatherList, object: nil)
    }

    var onDataUpdated: (() -> Void)?

    @objc private func dataManagerDidUpdateData() {
        DispatchQueue.main.async {
            self.onDataUpdated?()
        }
    }

    func getTimeString(index: Int) -> String? {
        guard let date = weatherDataManager.tomorrowWeatherList[index].dateText else { return "" }
        return  Date.dateToHours(date: date)
    }

    func getTempString(index: Int) -> String? {
        guard let temp = weatherDataManager.tomorrowWeatherList[index].tempInfo?.temp else { return "" }
        let roundedTemp = round(temp)
        return "\(Int(roundedTemp))°C"
    }

    func getIconImageWithColor(index: Int) -> UIImage? {
        guard let textColor = weatherDataManager.mainWeater?.textColor else { return nil }
        guard let icon = weatherDataManager.tomorrowWeatherList[index].weather?.first?.icon else { return nil }
        return weatherDataManager.setImage(iconString: icon)?.withTintColor(textColor)
    }

    func getDayAfterTomorrowTimeString(index: Int) -> String? {
        guard let date = weatherDataManager.dayAfterTomorrowWeatherList[index].dateText else { return "" }
        return  Date.dateToHours(date: date)
    }

    func getDayAfterTomorrowTempString(index: Int) -> String? {
        guard let temp = weatherDataManager.dayAfterTomorrowWeatherList[index].tempInfo?.temp else { return "" }
        let roundedTemp = round(temp)
        return "\(Int(roundedTemp))°C"
    }

    func getDayAfterTomorrowIconImageWithColor(index: Int) -> UIImage? {
        guard let textColor = weatherDataManager.mainWeater?.textColor else { return nil }
        guard let icon = weatherDataManager.dayAfterTomorrowWeatherList[index].weather?.first?.icon else { return nil }
        return weatherDataManager.setImage(iconString: icon)?.withTintColor(textColor)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
