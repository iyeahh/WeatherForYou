//
//  WeatherDataManager+.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/19/23.
//

import UIKit

extension Notification.Name {
    static let cityName = Notification.Name("cityName")
    static let mainWeather = Notification.Name("mainWeather")
    static let todayWeatherList = Notification.Name("todayWeatherList")
    static let tomorrowWeatherList = Notification.Name("tomorrowWeatherList")
    static let dayAfterTomorrowWeatherList = Notification.Name("dayAfterTomorrowWeatehrList")
    static let weekWeatherList = Notification.Name("weekWeatherList")
}

extension WeatherDataManager {
    func setImage(iconString: String) -> UIImage? {
        switch iconString {
        case "01n", "01d":
            return UIImage.weatherImage.sun
        case "02n", "02d":
            return UIImage.weatherImage.cloudy
        case "03n", "03d":
            return UIImage.weatherImage.cloud
        case "04n", "04d":
            return UIImage.weatherImage.cloudCloud
        case "09n", "09d", "10n", "10d":
            return UIImage.weatherImage.rain
        case "11n", "11d":
            return UIImage.weatherImage.storm
        case "13n", "13d":
            return UIImage.weatherImage.hail
        case "50n", "50d":
            return UIImage.weatherImage.fog
        default:
            return UIImage.weatherImage.sun
        }
    }

    func setbackgroundColor(iconString: String) -> (UIColor, UIColor) {
        switch iconString {
        case "01n", "01d", "02n", "02d":
            return UIColor.weatherTheme.sun
        case "03n", "03d", "04n", "04d", "50n", "50d":
            return UIColor.weatherTheme.cloud
        case "09n", "09d", "10n", "10d", "11n", "11d":
            return UIColor.weatherTheme.rain
        case "13n", "13d":
            return UIColor.weatherTheme.snow
        default:
            return UIColor.weatherTheme.sun
        }
    }

    func getImageForWeek(message: String) -> UIImage? {
        switch message {
        case "맑음":
            return UIImage.weatherImage.sun
        case "구름많음":
            return UIImage.weatherImage.cloudCloud
        case "구름많고 비", "구름많고 비/눈", "구름많고 소나기", "흐리고 비", "흐리고 비/눈", "흐리고 소나기":
            return UIImage.weatherImage.rain
        case "구름많고 눈", "흐리고 눈":
            return UIImage.weatherImage.hail
        case "흐림":
            return UIImage.weatherImage.fog
        default:
            return UIImage.weatherImage.sun
        }
    }

    func getRegionCodeForWeek(city: String) -> String {
        switch city {
        case "서울특별시":
            return "11B10101"
        case "부산광역시":
            return "11H20201"
        case "인천광역시":
            return "11B20201"
        case "대구광역시":
            return "11H10701"
        case "대전광역시":
            return "11C20401"
        case "광주광역시":
            return "11F20501"
        case "경기도":
            return "11B20601"
        case "울산광역시":
            return "11H20101"
        case "충청남도":
            return "11C20301"
        case "충청북도":
            return "11C10301"
        case "경상남도":
            return "11H20301"
        case "경상북도":
            return "11H10201"
        case "전라남도":
            return "11F20401"
        case "전라북도":
            return "11F10201"
        case "제주특별자치도":
            return "11G00201"
        case "강원도":
            return "11D10401"
        default:
            return "11B10101"
        }
    }

    func getImageRegionCodeForWeek(city: String) -> String {
        switch city {
        case "서울특별시", "인천광역시", "경기도":
            return "11B00000"
        case "부산광역시", "울산광역시", "경상남도":
            return "11H20000"
        case "대전광역시", "충청남도":
            return "11C20000"
        case "충청북도":
            return "11C10000"
        case "경상북도", "대구광역시":
            return "11H10000"
        case "전라남도", "광주광역시":
            return "11F20000"
        case "전라북도":
            return "11F10000"
        case "제주특별자치도":
            return "11G00201"
        case "강원도":
            return "11D20000"
        default:
            return "11B00000"
        }
    }
}
