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
            weatherImageView.widthAnchor.constraint(equalToConstant: 200),
            weatherImageView.heightAnchor.constraint(equalToConstant: 200),

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
    }

    func registerCollecionViewCell() {
        collectionView.register(HourlyWeatherCollectionViewCell.self, forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.identifier)
    }

    func setupCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func start(x: Double, y: Double) {
        networkManager.fetchWeather(xCoordinate: x, yCoordinate: y) { result in
            let date = self.dateFormatter()

            switch result {
            case .success(let weather):
                guard let currentWeather = weather else { return }
                DispatchQueue.main.async {
                    self.dateLabel.text = date
                    self.locationLabel.text = self.city
                    self.tempRangeLabel.text = "최저: \(currentWeather.tempMin)°C / 최고 \(currentWeather.tempMax)°C"
                    self.temperatureLabel.text = "\(currentWeather.temperature)°C"
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
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEE"

        return dateFormatter.string(from: nowDate)
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCollectionViewCell.identifier, for: indexPath)
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

        start(x: latitude, y: longitude)
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
