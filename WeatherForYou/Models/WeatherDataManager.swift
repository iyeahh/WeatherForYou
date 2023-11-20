//
//  WeatherDataManager.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/19/23.
//

import UIKit
import CoreLocation

final class WeatherDataManager: NSObject {
    static let shared = WeatherDataManager()

    let networkManager = NetworkManager.shared
    let locationManager = CLLocationManager()

    var weekWeatherTemp: WeekWeatherTemp?
    var weekWeatherRainAndImageData: WeekWeatherRainAndImageData?

    var cityName: String = "" {
        didSet {
            NotificationCenter.default.post(name: .cityName, object: self)
        }
    }

    var mainWeater: MainWeater? {
        didSet {
            NotificationCenter.default.post(name: .mainWeather, object: self)
        }
    }

    var todayWeatherList: [WeatherInfo] = [] {
        didSet {
            NotificationCenter.default.post(name: .todayWeatherList, object: self)
        }
    }

    var tomorrowWeatherList: [WeatherInfo] = [] {
        didSet {
            NotificationCenter.default.post(name: .tomorrowWeatherList, object: self)
        }
    }

    var dayAfterTomorrowWeatherList: [WeatherInfo] = [] {
        didSet {
            NotificationCenter.default.post(name: .dayAfterTomorrowWeatherList, object: self)
        }
    }

    var weekWeatherArray: [WeekWeatherEntity] = [] {
        didSet {
            NotificationCenter.default.post(name: .weekWeatherList, object: self)
        }
    }

    private override init() {
        super.init()
    }

    func setupCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchWeatherDataWith(lat: String, lon: String) {
        networkManager.fetchCurrentWeather(lat: lat, lon: lon) { result in
            switch result {
            case .success(let weather):
                guard
                    let temp = weather.temp?.temp,
                    let feelsLikeTemp = weather.temp?.feelsLike,
                    let iconString = weather.weather?.first?.icon,
                    let iconImage = self.setImage(iconString: iconString) else { return }

                let roundedTemp = round(temp)
                let roundedFeelsLikeTemp = round(feelsLikeTemp)
                let color = self.setbackgroundColor(iconString: iconString)

                var textColor = UIColor.white
                if iconString == "13n" || iconString == "13d" {
                    textColor = .darkGray
                }

                self.mainWeater = MainWeater(dateString: Date.currentDateToString(), feelsLikeTemp: roundedFeelsLikeTemp, weatherImage: iconImage.makeShadow(), currentTemp: roundedTemp, textColor: textColor, backgrounColor: color)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        networkManager.fetch3DaysForecast(lat: lat, lon: lon) { result in
            switch result {
            case .success(let forecast):
                guard
                    let todayWeather = forecast.weatherInfoList?.prefix(10),
                    let tomorrowWeather = forecast.weatherInfoList?[6..<14],
                    let dayAfterTomorrowWeather = forecast.weatherInfoList?[14..<22] else { return }

                self.todayWeatherList = Array(todayWeather)
                self.tomorrowWeatherList = Array(tomorrowWeather)
                self.dayAfterTomorrowWeatherList = Array(dayAfterTomorrowWeather)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func fetchWeekWeatherDataWith(regionCode: String, imageRegionCode: String) {
        let group = DispatchGroup()
        group.enter()

        networkManager.fetchWeekWeather(location: regionCode, date: Date.currentDataForWeek()) { result in
            switch result {
            case .success(let weekWeather):
                guard let weekWeatherTemp = weekWeather.response?.weekWeatherResponse?.weekWeatherItems?.weekWeatherTempList?.first else { return }
                self.weekWeatherTemp = weekWeatherTemp
                group.leave()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.enter()
        networkManager.fetchWeekWeatherRainAndImage(location: imageRegionCode, date: Date.currentDataForWeek()) { result in
            switch result {
            case .success(let weekWeatherImage):
                guard let weekWeatherRainAndImage = weekWeatherImage.response?.weekWeatherImageResponse?.weekWeatherImageItems?.weekWeatherRainAndImageList?.first else { return }
                self.weekWeatherRainAndImageData = weekWeatherRainAndImage
                group.leave()

            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.notify(queue: .global()) { [weak self] in
            guard
                let temp = self?.weekWeatherTemp,
                let rainAndImage = self?.weekWeatherRainAndImageData else { return }
            self?.convertWeekWeather(temp: temp, rainAndImage: rainAndImage)
        }
    }

    func convertWeekWeather(temp: WeekWeatherTemp, rainAndImage: WeekWeatherRainAndImageData) {
        guard
            let thirdWeather = rainAndImage.later3DaysWeather,
            let fourthWeather = rainAndImage.later4DaysWeather,
            let fifthWeather = rainAndImage.later5DaysWeather,
            let sixthWeather = rainAndImage.later6DaysWeather,
            let seventhWeather = rainAndImage.later7DaysWeather,
            let eighthWeather = rainAndImage.later8DaysWeather,
            let ninethWeather = rainAndImage.later9DaysWeather,
            let tenthWeather = rainAndImage.later10DaysWeather else { return }


        let third = WeekWeatherEntity(afterHours: 72, tempImage: getImageForWeek(message: thirdWeather), tempMax: temp.later3DaysMaxTemp, tempMin: temp.later3DaysMinTemp, rain: rainAndImage.later3DaysRain)
        let fourth = WeekWeatherEntity(afterHours: 96, tempImage: getImageForWeek(message: fourthWeather), tempMax: temp.later4DaysMaxTemp, tempMin: temp.later4DaysMinTemp, rain: rainAndImage.later4DaysRain)
        let fifth = WeekWeatherEntity(afterHours: 120, tempImage: getImageForWeek(message: fifthWeather), tempMax: temp.later5DaysMaxTemp, tempMin: temp.later5DaysMinTemp, rain: rainAndImage.later5DaysRain)
        let sixth = WeekWeatherEntity(afterHours: 144, tempImage: getImageForWeek(message: sixthWeather), tempMax: temp.later6DaysMaxTemp, tempMin: temp.later6DaysMinTemp, rain: rainAndImage.later6DaysRain)
        let seventh = WeekWeatherEntity(afterHours: 168, tempImage: getImageForWeek(message: seventhWeather), tempMax: temp.later7DaysMaxTemp, tempMin: temp.later7DaysMinTemp, rain: rainAndImage.later7DaysRain)
        let eighth = WeekWeatherEntity(afterHours: 192, tempImage: getImageForWeek(message: eighthWeather), tempMax: temp.later8DaysMaxTemp, tempMin: temp.later8DaysMinTemp, rain: rainAndImage.later8DaysRain)
        let nineth = WeekWeatherEntity(afterHours: 216, tempImage: getImageForWeek(message: ninethWeather), tempMax: temp.later9DaysMaxTemp, tempMin: temp.later9DaysMinTemp, rain: rainAndImage.later9DaysRain)
        let tenth = WeekWeatherEntity(afterHours: 240, tempImage: getImageForWeek(message: tenthWeather), tempMax: temp.later10DaysMaxTemp, tempMin: temp.later10DaysMinTemp, rain: rainAndImage.later10DaysRain)

        weekWeatherArray = [third, fourth, fifth, sixth, seventh, eighth, nineth, tenth]
    }
}

extension WeatherDataManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        locationManager.stopUpdatingLocation()

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        getCityNameFromCoordinates(latitude: latitude, longitude: longitude) {
            cityName in
            self.cityName = cityName
        }

        let strLat = String(latitude)
        let strLon = String(longitude)

        fetchWeatherDataWith(lat: strLat, lon: strLon)
    }

    func getCityNameFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let geocoder = CLGeocoder()
        let local = Locale(identifier: "Ko-kr")

        geocoder.reverseGeocodeLocation(location, preferredLocale: local) { (placemarks, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                if let cityName = placemark.locality, let subCityName = placemark.subLocality {

                    guard let city = placemark.administrativeArea else { return }
                    let regionCode = self.getRegionCodeForWeek(city: city)
                    let imageRegionCode = self.getImageRegionCodeForWeek(city: city)

                    self.fetchWeekWeatherDataWith(regionCode: regionCode, imageRegionCode: imageRegionCode)
                    completion(cityName + " " + subCityName)
                    return
                } else {
                    print("도시 이름을 찾을 수 없음")
                    completion(" ")
                    return
                }
            } else {
                print("장소 정보를 찾을 수 없음")
                completion(" ")
                return
            }
        }
    }
}
