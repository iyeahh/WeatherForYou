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

    var lat: String = ""
    var lon: String = ""

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

    let skyStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "맑고 구름 조금"
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
        view.addSubview(skyStatusLabel)
        view.addSubview(weatherImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(collectionView)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        skyStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 40),

            skyStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skyStatusLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 3),

            weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImageView.topAnchor.constraint(equalTo: skyStatusLabel.bottomAnchor, constant: 80),
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

    func start() {
        let date = getDate()
        let time = getTime()

        networkManager.fetchWeather(dateString: date, timeString: time, xCoordinate: lat, yCoordinate: lon) { result in
            switch result {
            case .success(let weather):
                guard let todayWeather = weather else { return }
                DispatchQueue.main.async {
                    self.dateLabel.text = todayWeather.date
                    self.skyStatusLabel.text = todayWeather.skyStatus
                    self.temperatureLabel.text = todayWeather.temperature
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func getDate() -> String {
        let date = Date()

        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyyMMdd"
        return myDateFormatter.string(from: date)
    }

    func getTime() -> String {
        let date = Date()

        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "HH00"
        return myDateFormatter.string(from: date)
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

        let latitude = Int(location.coordinate.latitude)
        let longitude = Int(location.coordinate.longitude)

        lat = String(latitude)
        lon = String(longitude)

        start()
    }
}
