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

    let screenHeight: CGFloat = UIScreen.main.bounds.height

    var city: String = ""
    var weatherList: [WeatherInfo] = []

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()

    let tempRangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    var weatherImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.textColor = .white
        return label
    }()

    let todayCollectionView: UICollectionView = {
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
        view.addSubview(todayCollectionView)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        tempRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        todayCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: screenHeight * 0.06),

            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: screenHeight * 0.06),

            tempRangeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempRangeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 3),

            weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            weatherImageView.widthAnchor.constraint(equalToConstant: 180),
            weatherImageView.heightAnchor.constraint(equalToConstant: 180),

            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor),

            todayCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            todayCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            todayCollectionView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: screenHeight * 0.06),
            todayCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    func setupCollectionView() {
        todayCollectionView.dataSource = self
        todayCollectionView.delegate = self
        todayCollectionView.showsHorizontalScrollIndicator = false
    }

    func registerCollecionViewCell() {
        todayCollectionView.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: TodayCollectionViewCell.identifier)
    }

    func setupCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchWeatherDataWith(lat: String, lon: String) {
        networkManager.fetchWeather(lat: lat, lon: lon) { result in
            let date = self.currentDateToString()

            switch result {
            case .success(let weather):
                guard let temp = weather.temp?.temp else { return }
                guard let feelsLikeTemp = weather.temp?.feelsLike else { return }
                let roundedTemp = round(temp)
                let roundedFeelsLikeTemp = round(feelsLikeTemp)
                guard let image = self.setImage(iconString: (weather.weather?.first?.icon)!) else { return }
                let shadowImage = self.makeShadow(image: image)

                DispatchQueue.main.async {
                    if (weather.weather?.first?.icon)! == "13n" || (weather.weather?.first?.icon)! == "13d" {
                        self.dateLabel.textColor = .darkGray
                        self.locationLabel.textColor = .darkGray
                        self.tempRangeLabel.textColor = .darkGray
                        self.temperatureLabel.textColor = .darkGray
                    }
                    self.dateLabel.text = date
                    self.locationLabel.text = self.city
                    self.tempRangeLabel.text = "체감온도: \(Int(roundedFeelsLikeTemp))°C"
                    self.temperatureLabel.text = "\(Int(roundedTemp))°C"
                    self.weatherImageView.image = shadowImage
                    let (color1, color2) = self.setbackgroundColor(iconString: (weather.weather?.first?.icon)!)
                    let layer = self.setBackground(color1: color1, color2: color2)
                    self.view.layer.insertSublayer(layer, at: 0)
                    self.todayCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        networkManager.fetchForecast(lat: lat, lon: lon) { result in
            switch result {
            case .success(let forecast):
                self.weatherList = Array((forecast.weatherInfoList?.prefix(10))!)
                DispatchQueue.main.async {
                    self.todayCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func currentDateToString() -> String {
        let nowDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"

        return dateFormatter.string(from: nowDate)
    }

    func dateToHours(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        let convertDate = dateFormatter.date(from: date)

        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "HH시"

        return myDateFormatter.string(from: convertDate!)
    }

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

    func makeShadow(image: UIImage?) -> UIImage? {

        guard let originalImage = image else { return nil }

        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, 0.0)

        if let context = UIGraphicsGetCurrentContext() {
            let shadowOffset = CGSize(width: 5, height: 5)
            let shadowBlur: CGFloat = 20.0
            let shadowColor = UIColor.black.cgColor

            context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor)

            originalImage.draw(at: .zero)

            let imageWithShadow = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            if let imageWithShadow = imageWithShadow {
                return imageWithShadow
            }
        }
        return nil
    }

    func setBackground(color1: UIColor, color2: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        return gradientLayer
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayCollectionViewCell.identifier, for: indexPath) as! TodayCollectionViewCell
        if dateLabel.textColor == .darkGray {
            cell.temperatureLabel.textColor = .darkGray
            cell.timeLabel.textColor = .darkGray
        }

        if let date = weatherList[indexPath.row].dateText {
            cell.timeLabel.text = dateToHours(date: date)
        }

        if let temp = weatherList[indexPath.row].tempInfo?.temp {
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

        fetchWeatherDataWith(lat: strLat, lon: strLon)
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
                } else {
                    print("도시 이름을 찾을 수 없음")
                }
            } else {
                print("장소 정보를 찾을 수 없음")
            }
        }
    }
}
