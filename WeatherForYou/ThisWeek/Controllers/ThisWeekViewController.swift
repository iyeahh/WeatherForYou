//
//  ThisWeekViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import UIKit
import CoreLocation

class ThisWeekViewController: UIViewController {

    let networkManager = NetworkManager.shared
    let locationManager = CLLocationManager()

    var city: String = ""
    var weekWeatherTemp: WeekWeatherTemp?
    var weekWeatherRainAndImage: WeekWeatherRainAndImage?
    var weekWeatherArray: [WeekWeatherEntity] = []

    let group = DispatchGroup()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()

    let thisWeekTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTableView()
        registerTableView()
        setupCoreLocation()
    }

    func setupLayout() {
        view.addSubview(locationLabel)
        view.addSubview(thisWeekTableView)

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        thisWeekTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),

            thisWeekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            thisWeekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            thisWeekTableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 50),
            thisWeekTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    func setupTableView() {
        thisWeekTableView.delegate = self
        thisWeekTableView.dataSource = self
        thisWeekTableView.rowHeight = 70
        thisWeekTableView.separatorStyle = .none
    }


    func registerTableView() {
        thisWeekTableView.register(WeekWeatherTableViewCell.self, forCellReuseIdentifier: WeekWeatherTableViewCell.identifier)
    }

    func setupCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchWeekWeatherDataWith(regionCode: String, imageRegionCode: String) {
        let date = Date.currentDataForWeek()
        group.enter()
        networkManager.fetchWeekWeather(location: regionCode, date: date) { result in
            switch result {
            case .success(let weekWeather):
                guard let item = weekWeather.response?.weekWeatherResponse?.weekWeatherItems?.weekWeatherTempList?.first else { return }
                self.weekWeatherTemp = item
                self.group.leave()
                DispatchQueue.main.async {
                    let layer = self.setBackground(color1: UIColor.weatherTheme.baseReversed.0 ,color2: UIColor.weatherTheme.baseReversed.1)
                    self.view.layer.insertSublayer(layer, at: 0)
                    self.locationLabel.text = self.city
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.enter()
        networkManager.fetchWeekWeatherImage(location: imageRegionCode, date: date) { result in
            switch result {
            case .success(let weekWeatherImage):
                guard let item = weekWeatherImage.response?.weekWeatherImageResponse?.weekWeatherImageItems?.weekWeatherRainAndImageList?.first else { return }
                self.weekWeatherRainAndImage = item
                self.group.leave()

            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.notify(queue: .global()) { [weak self] in
            guard let weekWeather = self?.weekWeatherTemp else { return }
            guard let image = self?.weekWeatherRainAndImage else { return }
            self?.convertWeekWeather(temp: weekWeather, weatherAndRain: image)

            DispatchQueue.main.async {
                self?.thisWeekTableView.reloadData()
            }
        }
    }

    func setBackground(color1: UIColor, color2: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        return gradientLayer
    }

    func convertWeekWeather(temp: WeekWeatherTemp, weatherAndRain: WeekWeatherRainAndImage) {
        let third = WeekWeatherEntity(afterHours: 72, tempImage: getImage(message: weatherAndRain.later3DaysWeather!), tempMax: temp.later3DaysMaxTemp, tempMin: temp.later3DaysMinTemp, rain: weatherAndRain.later3DaysRain)
        let fourth = WeekWeatherEntity(afterHours: 96, tempImage: getImage(message: weatherAndRain.later4DaysWeather!), tempMax: temp.later4DaysMaxTemp, tempMin: temp.later4DaysMinTemp, rain: weatherAndRain.later4DaysRain)
        let fifth = WeekWeatherEntity(afterHours: 120, tempImage: getImage(message: weatherAndRain.later5DaysWeather!), tempMax: temp.later5DaysMaxTemp, tempMin: temp.later5DaysMinTemp, rain: weatherAndRain.later5DaysRain)
        let sixth = WeekWeatherEntity(afterHours: 144, tempImage: getImage(message: weatherAndRain.later6DaysWeather!), tempMax: temp.later6DaysMaxTemp, tempMin: temp.later6DaysMinTemp, rain: weatherAndRain.later6DaysRain)
        let seventh = WeekWeatherEntity(afterHours: 168, tempImage: getImage(message: weatherAndRain.later7DaysWeather!), tempMax: temp.later7DaysMaxTemp, tempMin: temp.later7DaysMinTemp, rain: weatherAndRain.later7DaysRain)
        let eighth = WeekWeatherEntity(afterHours: 192, tempImage: getImage(message: weatherAndRain.later8DaysWeather!), tempMax: temp.later8DaysMaxTemp, tempMin: temp.later8DaysMinTemp, rain: weatherAndRain.later8DaysRain)
        let nineth = WeekWeatherEntity(afterHours: 216, tempImage: getImage(message: weatherAndRain.later9DaysWeather!), tempMax: temp.later9DaysMaxTemp, tempMin: temp.later9DaysMinTemp, rain: weatherAndRain.later9DaysRain)
        let tenth = WeekWeatherEntity(afterHours: 240, tempImage: getImage(message: weatherAndRain.later10DaysWeather!), tempMax: temp.later10DaysMaxTemp, tempMin: temp.later10DaysMinTemp, rain: weatherAndRain.later10DaysRain)

        weekWeatherArray = [third, fourth, fifth, sixth, seventh, eighth, nineth, tenth]
    }

    func getImage(message: String) -> UIImage? {
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

    func getRegionCode(city: String) -> String {
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

    func getImageRegionCode(city: String) -> String {
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

extension ThisWeekViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekWeatherArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeekWeatherTableViewCell.identifier, for: indexPath) as! WeekWeatherTableViewCell
        let weekWeather = weekWeatherArray[indexPath.row]
        guard let tempMax = weekWeather.tempMax,
              let tempMin = weekWeather.tempMin,
              let afterHours = weekWeather.afterHours,
              let tempImage = weekWeather.tempImage,
              let rain = weekWeather.rain else { return cell }

        cell.dateLabel.text = Date.dateFormatterForWeek(afterHours: afterHours)
        cell.weatherImageView.image = tempImage
        cell.tempMinMaxLabel.text = "\(tempMax)°C / \(tempMin)°C"
        cell.rainLabel.text = "\(rain)%"

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        return cell
    }
}

extension ThisWeekViewController: UITableViewDelegate {

}

extension ThisWeekViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        locationManager.stopUpdatingLocation()

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        getCityNameFromCoordinates(latitude: latitude, longitude: longitude)
    }

    func getCityNameFromCoordinates(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let geocoder = CLGeocoder()
        let local = Locale(identifier: "Ko-kr")

        geocoder.reverseGeocodeLocation(location, preferredLocale: local) { [self] (placemarks, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                if let cityName = placemark.locality, let subCityName = placemark.subLocality {
                    self.city = cityName + " " + subCityName
                    guard let city = placemark.administrativeArea else { return }
                    let regionCode = getRegionCode(city: city)
                    let imageRegionCode = getImageRegionCode(city: city)

                    self.fetchWeekWeatherDataWith(regionCode: regionCode, imageRegionCode: imageRegionCode)
                } else {
                    print("도시 이름을 찾을 수 없음")
                }
            } else {
                print("장소 정보를 찾을 수 없음")
            }
        }
    }
}
