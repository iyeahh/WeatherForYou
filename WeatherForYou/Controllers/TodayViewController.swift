//
//  TodayViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 10/27/23.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController {

    let networkManager = NetworkManager.shared
    let locationManager = CLLocationManager()

    var city: String = ""
    var weatherList: [WeatherInfo] = []

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023년 11월 1일 수요일"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "서울 관악구"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()

    let tempRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "최저: 8 / 최고: 20"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "think3.001")
        imageView.tintColor = .white
        return imageView
    }()

    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "18도"
        label.font = UIFont.systemFont(ofSize: 40)
        label.textColor = .white
        return label
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumLineSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        setupLayout()
        setupCollectionView()
        registerCollecionViewCell()
        setupCoreLocation()
    }

    private func setupLayout() {
        view.addSubview(dateLabel)
        view.addSubview(locationLabel)
        view.addSubview(tempRangeLabel)
        view.addSubview(weatherImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(collectionView)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        tempRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 40),

            tempRangeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempRangeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 3),

            weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImageView.topAnchor.constraint(equalTo: tempRangeLabel.bottomAnchor, constant: 80),
            weatherImageView.widthAnchor.constraint(equalToConstant: 180),
            weatherImageView.heightAnchor.constraint(equalToConstant: 180),

            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 30),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            collectionView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 30),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
    }

    func registerCollecionViewCell() {
        collectionView.register(HourlyWeatherCollectionViewCell.self, forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.identifier)
    }

    func setupCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func start(x: String, y: String) {
        networkManager.fetchWeather(lat: x, lon: y) { result in
            let date = self.dateFormatter()

            switch result {
            case .success(let weather):
                guard let temp = weather.main?.temp else { return }
                guard let feelsLikeTemp = weather.main?.feelsLike else { return }
                let roundedTemp = round(temp)
                let roundedFeelsLikeTemp = round(feelsLikeTemp)

                DispatchQueue.main.async {
                    self.dateLabel.text = date
                    self.locationLabel.text = self.city
                    self.tempRangeLabel.text = "체감온도: \(Int(roundedFeelsLikeTemp))°C"
                    self.temperatureLabel.text = "\(Int(roundedTemp))°C"
                    self.weatherImageView.image = self.setImage(iconString: (weather.weather?.first?.icon)!)
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        networkManager.fetchForecast(lat: x, lon: y) { result in

            switch result {
            case .success(let forecast):
                self.weatherList = Array((forecast.weatherInfoList?.prefix(10))!)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func dateFormatter() -> String {
        let nowDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"

        return dateFormatter.string(from: nowDate)
    }

    func setImage(iconString: String) -> UIImage? {
        switch iconString {
        case "01n", "01d":
            return UIImage(named: "sunny")
        case "02n", "02d":
            return UIImage(named: "clear-sky")
        case "03n", "03d", "04n", "04d", "50n", "50d":
            return UIImage(named: "cloud")
        case "09n", "09d":
            return UIImage(named: "rainy-day")
        case "10n", "10d":
            return UIImage(named: "rainy")
        case "11n", "11d":
            return UIImage(named: "lighting")
        case "13n", "13d":
            return UIImage(named: "snowflake")
        default:
            return UIImage(named: "sunny")
        }
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCollectionViewCell.identifier, for: indexPath) as! HourlyWeatherCollectionViewCell

        if let date = weatherList[indexPath.row].dtTxt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
            let convertDate = dateFormatter.date(from: date)

            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "HH시"
            let convertStr = myDateFormatter.string(from: convertDate!)

            cell.timeLabel.text = convertStr
        }

        if let temp = weatherList[indexPath.row].mainInfo?.temp {
            let roundedTemp = round(temp)
            cell.temperatureLabel.text = "\(Int(roundedTemp))°C"
        }

        cell.weatherImageView.image = setImage(iconString: (weatherList[indexPath.row].weather?.first?.icon)!)

        return cell
    }
}

extension TodayViewController: UICollectionViewDelegate {

}

extension TodayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        locationManager.stopUpdatingLocation()

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        getCityNameFromCoordinates(latitude: latitude, longitude: longitude)

        let strLat = String(latitude)
        let strLon = String(longitude)

        start(x: strLat, y: strLon)
    }

    func getCityNameFromCoordinates(latitude: Double, longitude: Double) {
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
                    self.city = cityName + " " + subCityName
                    print(self.city)
                } else {
                    print("도시 이름을 찾을 수 없음")
                }
            } else {
                print("장소 정보를 찾을 수 없음")
            }
        }
    }
}
