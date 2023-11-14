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
    var regionCode: String = ""
    var imageRegionCode: String = ""
    var array: Item?
    var imageArray: ImageItem?
    var weekWeatherArray: [WeekWeatherEntity] = []

    let group = DispatchGroup()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "서울 관악구"
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
                guard let item = weekWeather.response?.body?.items?.item?.first else { return }
                self.array = item
                self.group.leave()
                DispatchQueue.main.async {
                    let layer = self.setBackground(color1: #colorLiteral(red: 0.2927551866, green: 0.2779331803, blue: 0.5755700469, alpha: 1),color2: #colorLiteral(red: 0.6723831892, green: 0.5646241307, blue: 0.7415238023, alpha: 1))
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
                guard let item = weekWeatherImage.response?.body?.items?.item?.first else { return }
                self.imageArray = item
                self.group.leave()

            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.notify(queue: .global()) { [weak self] in
            guard let weekWeather = self?.array else {
                print("예보없음")
                return }
            guard let image = self?.imageArray else {
                print("이미지없음")
                return }
            self?.convertWeekWeather(array: weekWeather, imageArray: image)

            DispatchQueue.main.async {
                self?.thisWeekTableView.reloadData()
            }
        }

    }

    func dateFormatter() -> String {
        let nowDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd0600"

        return dateFormatter.string(from: nowDate)
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

    func convertWeekWeather(array: Item, imageArray: ImageItem) {
        let third = WeekWeatherEntity(afterHours: 72, tempMin: array.taMin3, tempMax: array.taMax3, tempImage: getImage(message: imageArray.wf3Am!), rain: imageArray.rnSt3Am)
        let fourth = WeekWeatherEntity(afterHours: 96, tempMin: array.taMin4, tempMax: array.taMax4, tempImage: getImage(message: imageArray.wf4Am!), rain: imageArray.rnSt4Am)
        let fifth = WeekWeatherEntity(afterHours: 120, tempMin: array.taMin5, tempMax: array.taMax5, tempImage: getImage(message: imageArray.wf5Am!), rain: imageArray.rnSt5Am)
        let sixth = WeekWeatherEntity(afterHours: 144, tempMin: array.taMin6, tempMax: array.taMax6, tempImage: getImage(message: imageArray.wf6Am!), rain: imageArray.rnSt6Am)
        let seventh = WeekWeatherEntity(afterHours: 168, tempMin: array.taMin7, tempMax: array.taMax7, tempImage: getImage(message: imageArray.wf7Am!), rain: imageArray.rnSt7Am)
        let eighth = WeekWeatherEntity(afterHours: 192, tempMin: array.taMin8, tempMax: array.taMax8, tempImage: getImage(message: imageArray.wf8!), rain: imageArray.rnSt8)
        let nineth = WeekWeatherEntity(afterHours: 216, tempMin: array.taMin9, tempMax: array.taMax9, tempImage: getImage(message: imageArray.wf9!), rain: imageArray.rnSt9)
        let tenth = WeekWeatherEntity(afterHours: 240, tempMin: array.taMin10, tempMax: array.taMax10, tempImage: getImage(message: imageArray.wf10!), rain: imageArray.rnSt10)

        weekWeatherArray = [third, fourth, fifth, sixth, seventh, eighth, nineth, tenth]
    }

    func getImage(message: String) -> UIImage? {
        switch message {
        case "맑음":
            return UIImage(named: "sun")
        case "구름많음":
            return UIImage(named: "cloudcloud")
        case "구름많고 비", "구름많고 비/눈", "구름많고 소나기", "흐리고 비", "흐리고 비/눈", "흐리고 소나기":
            return UIImage(named: "rain")
        case "구름많고 눈", "흐리고 눈":
            return UIImage(named: "hail")
        case "흐림":
            return UIImage(named: "fog")
        default:
            return UIImage(named: "sun")
        }
    }
}

extension ThisWeekViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekWeatherArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeekWeatherTableViewCell.identifier, for: indexPath) as! WeekWeatherTableViewCell
        guard let tempMax = weekWeatherArray[indexPath.row].tempMax,
              let tempMin = weekWeatherArray[indexPath.row].tempMin,
              let afterHours = weekWeatherArray[indexPath.row].afterHours,
              let tempImage = weekWeatherArray[indexPath.row].tempImage,
              let rain = weekWeatherArray[indexPath.row].rain else { return cell }

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
                    switch placemark.administrativeArea {
                    case "서울특별시":
                        self.regionCode = "11B10101"
                    case "부산광역시":
                        self.regionCode = "11H20201"
                    case "인천광역시":
                        self.regionCode = "11B20201"
                    case "대구광역시":
                        self.regionCode = "11H10701"
                    case "대전광역시":
                        self.regionCode = "11C20401"
                    case "광주광역시":
                        self.regionCode = "11F20501"
                    case "경기도":
                        self.regionCode = "11B20601"
                    case "울산광역시":
                        self.regionCode = "11H20101"
                    case "충청남도":
                        self.regionCode = "11C20301"
                    case "충청북도":
                        self.regionCode = "11C10301"
                    case "경상남도":
                        self.regionCode = "11H20301"
                    case "경상북도":
                        self.regionCode = "11H10201"
                    case "전라남도":
                        self.regionCode = "11F20401"
                    case "전라북도":
                        self.regionCode = "11F10201"
                    case "제주특별자치도":
                        self.regionCode = "11G00201"
                    case "강원도":
                        self.regionCode = "11D10401"
                    default:
                        self.regionCode = "11B10101"
                    }

                    switch placemark.administrativeArea {
                    case "서울특별시", "인천광역시", "경기도":
                        self.imageRegionCode = "11B00000"
                    case "부산광역시", "울산광역시", "경상남도":
                        self.imageRegionCode = "11H20000"
                    case "대전광역시", "충청남도":
                        self.imageRegionCode = "11C20000"
                    case "충청북도":
                        self.imageRegionCode = "11C10000"
                    case "경상북도", "대구광역시":
                        self.imageRegionCode = "11H10000"
                    case "전라남도", "광주광역시":
                        self.imageRegionCode = "11F20000"
                    case "전라북도":
                        self.imageRegionCode = "11F10000"
                    case "제주특별자치도":
                        self.regionCode = "11G00201"
                    case "강원도":
                        self.regionCode = "11D20000"
                    default:
                        self.regionCode = "11B10101"
                    }
                    self.start(regionCode: self.regionCode, imageRegionCode: self.imageRegionCode)
                } else {
                    print("도시 이름을 찾을 수 없음")
                }
            } else {
                print("장소 정보를 찾을 수 없음")
            }
        }
    }
}
