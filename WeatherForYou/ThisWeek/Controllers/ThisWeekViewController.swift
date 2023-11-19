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
    var array: WeekWeatherTemp?
    var imageArray: WeekWeatherRainAndImage?
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

    func start(regionCode: String, imageRegionCode: String) {
        let date = dateFormatter()
        group.enter()
        networkManager.fetchWeekWeather(location: regionCode, date: date) { result in
            switch result {
            case .success(let weekWeather):
                guard let item = weekWeather.response?.weekWeatherResponse?.weekWeatherItems?.weekWeatherTempList?.first else { return }
                self.array = item
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
                self.imageArray = item
                self.group.leave()

            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.notify(queue: .global()) { [weak self] in
            guard let weekWeather = self?.array else { return }
            guard let image = self?.imageArray else { return }
            self?.convertWeekWeather(array: weekWeather, imageArray: image)

            DispatchQueue.main.async {
                self?.thisWeekTableView.reloadData()
            }
        }
    }

    func dateFormatter() -> String {
        let nowDate = Date()
        var afterHoursDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "HH"
        let after6DateFormatter = DateFormatter()
        after6DateFormatter.dateFormat = "yyyyMMdd0600"

        if Int(dateFormatter.string(from: nowDate))! < 06 {
            guard let date = Calendar.current.date(byAdding: .day, value: -1, to: nowDate) else { return "" }
            return after6DateFormatter.string(from: date)
        } else {
            return after6DateFormatter.string(from: nowDate)
        }
    }

    func dateFormatter(afterHours: Int) -> String {
        let nowDate = Date()
        var afterHoursDate = Date()

        if let date = Calendar.current.date(byAdding: .hour, value: afterHours, to: nowDate) {
            afterHoursDate = date
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "MM/dd(EEE)"

        return dateFormatter.string(from: afterHoursDate)
    }


    func setBackground(color1: UIColor, color2: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        return gradientLayer
    }

    func convertWeekWeather(array: WeekWeatherTemp, imageArray: WeekWeatherRainAndImage) {
        let third = WeekWeatherEntity(afterHours: 72, tempImage: getImage(message: imageArray.later3DaysWeather!), tempMax: array.later3DaysMaxTemp, tempMin: array.later3DaysMinTemp, rain: imageArray.later3DaysRain)
        let fourth = WeekWeatherEntity(afterHours: 96, tempImage: getImage(message: imageArray.later4DaysWeather!), tempMax: array.later4DaysMaxTemp, tempMin: array.later4DaysMinTemp, rain: imageArray.later4DaysRain)
        let fifth = WeekWeatherEntity(afterHours: 120, tempImage: getImage(message: imageArray.later5DaysWeather!), tempMax: array.later5DaysMaxTemp, tempMin: array.later5DaysMinTemp, rain: imageArray.later5DaysRain)
        let sixth = WeekWeatherEntity(afterHours: 144, tempImage: getImage(message: imageArray.later6DaysWeather!), tempMax: array.later6DaysMaxTemp, tempMin: array.later6DaysMinTemp, rain: imageArray.later6DaysRain)
        let seventh = WeekWeatherEntity(afterHours: 168, tempImage: getImage(message: imageArray.later7DaysWeather!), tempMax: array.later7DaysMaxTemp, tempMin: array.later7DaysMinTemp, rain: imageArray.later7DaysRain)
        let eighth = WeekWeatherEntity(afterHours: 192, tempImage: getImage(message: imageArray.later8DaysWeather!), tempMax: array.later8DaysMaxTemp, tempMin: array.later8DaysMinTemp, rain: imageArray.later8DaysRain)
        let nineth = WeekWeatherEntity(afterHours: 216, tempImage: getImage(message: imageArray.later9DaysWeather!), tempMax: array.later9DaysMaxTemp, tempMin: array.later9DaysMinTemp, rain: imageArray.later9DaysRain)
        let tenth = WeekWeatherEntity(afterHours: 240, tempImage: getImage(message: imageArray.later10DaysWeather!), tempMax: array.later10DaysMaxTemp, tempMin: array.later10DaysMinTemp, rain: imageArray.later10DaysRain)

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

        cell.dateLabel.text = dateFormatter(afterHours: afterHours)
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

                    self.start(regionCode: regionCode, imageRegionCode: imageRegionCode)
                } else {
                    print("도시 이름을 찾을 수 없음")
                }
            } else {
                print("장소 정보를 찾을 수 없음")
            }
        }
    }
}
