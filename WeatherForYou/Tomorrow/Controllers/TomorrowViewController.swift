//
//  TomorrowViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import UIKit
import CoreLocation

class TomorrowViewController: UIViewController {

    let networkManager = NetworkManager.shared
    let locationManager = CLLocationManager()

    let screenHeight: CGFloat = UIScreen.main.bounds.height

    var city: String = ""
    var tomorrowWeatherList: [WeatherInfo] = []
    var datAfterTomorrowWeatherList: [WeatherInfo] = []

    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()

    let tomorrowDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    let tomorrowCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumLineSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    let dayAfterTomorrowDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    let dayAfterTomorrowCollectionView: UICollectionView = {
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
        view.addSubview(locationLabel)
        view.addSubview(tomorrowDateLabel)
        view.addSubview(tomorrowCollectionView)
        view.addSubview(dayAfterTomorrowDateLabel)
        view.addSubview(dayAfterTomorrowCollectionView)

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        tomorrowDateLabel.translatesAutoresizingMaskIntoConstraints = false
        tomorrowCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dayAfterTomorrowDateLabel.translatesAutoresizingMaskIntoConstraints = false
        dayAfterTomorrowCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: screenHeight * 0.1),

            tomorrowDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            tomorrowDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            tomorrowDateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: screenHeight * 0.08),

            tomorrowCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            tomorrowCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            tomorrowCollectionView.topAnchor.constraint(equalTo: tomorrowDateLabel.bottomAnchor, constant: 30),
            tomorrowCollectionView.heightAnchor.constraint(equalToConstant: 100),

            dayAfterTomorrowDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            dayAfterTomorrowDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            dayAfterTomorrowDateLabel.topAnchor.constraint(equalTo: tomorrowCollectionView.bottomAnchor, constant: screenHeight * 0.08),

            dayAfterTomorrowCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            dayAfterTomorrowCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            dayAfterTomorrowCollectionView.topAnchor.constraint(equalTo: dayAfterTomorrowDateLabel.bottomAnchor, constant: 30),
            dayAfterTomorrowCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    func setupCollectionView() {
        tomorrowCollectionView.dataSource = self
        tomorrowCollectionView.delegate = self
        tomorrowCollectionView.showsHorizontalScrollIndicator = false
        dayAfterTomorrowCollectionView.dataSource = self
        dayAfterTomorrowCollectionView.delegate = self
        dayAfterTomorrowCollectionView.showsHorizontalScrollIndicator = false
    }

    func registerCollecionViewCell() {
        tomorrowCollectionView.register(TomorrowCollectionViewCell.self, forCellWithReuseIdentifier: TomorrowCollectionViewCell.identifier)
        dayAfterTomorrowCollectionView.register(DayAfterTomorrowCollectionViewCell.self, forCellWithReuseIdentifier: DayAfterTomorrowCollectionViewCell.identifier)
    }

    func setupCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchWeatherDataWith(lat: String, lon: String) {
        networkManager.fetchForecast(lat: lat, lon: lon) { result in

            switch result {
            case .success(let forecast):
                let date = Date.tomorrowAndNextDayToString()
                self.tomorrowWeatherList = Array((forecast.weatherInfoList?[6..<14])!)
                self.datAfterTomorrowWeatherList = Array((forecast.weatherInfoList?[14..<22])!)

                DispatchQueue.main.async {
                    self.tomorrowDateLabel.text = date.0
                    self.dayAfterTomorrowDateLabel.text = date.1
                    let layer = self.setBackground(color1: UIColor.weatherTheme.base.0,color2: UIColor.weatherTheme.base.1)
                    self.view.layer.insertSublayer(layer, at: 0)
                    self.locationLabel.text = self.city
                    self.tomorrowCollectionView.reloadData()
                    self.dayAfterTomorrowCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        case "09n", "09d":
            return UIImage.weatherImage.rain
        case "10n", "10d":
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

    func setBackground(color1: UIColor, color2: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        return gradientLayer
    }
}

extension TomorrowViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tomorrowCollectionView {
            return tomorrowWeatherList.count
        } else if collectionView == dayAfterTomorrowCollectionView {
            return datAfterTomorrowWeatherList.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == tomorrowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TomorrowCollectionViewCell.identifier, for: indexPath) as! TomorrowCollectionViewCell

            if let date = tomorrowWeatherList[indexPath.row].dateText {
                cell.timeLabel.text = Date.dateToHours(date: date)
            }

            if let temp = tomorrowWeatherList[indexPath.row].tempInfo?.temp {
                let roundedTemp = round(temp)
                cell.temperatureLabel.text = "\(Int(roundedTemp))°C"
            }

            cell.weatherImageView.image = setImage(iconString: (tomorrowWeatherList[indexPath.row].weather?.first?.icon)!)

            return cell

        } else if collectionView == dayAfterTomorrowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayAfterTomorrowCollectionViewCell.identifier, for: indexPath) as! DayAfterTomorrowCollectionViewCell

            if let date = datAfterTomorrowWeatherList[indexPath.row].dateText {
                cell.timeLabel.text = Date.dateToHours(date: date)
            }

            if let temp = datAfterTomorrowWeatherList[indexPath.row].tempInfo?.temp {
                let roundedTemp = round(temp)
                cell.temperatureLabel.text = "\(Int(roundedTemp))°C"
            }

            cell.weatherImageView.image = setImage(iconString: (datAfterTomorrowWeatherList[indexPath.row].weather?.first?.icon)!)

            return cell
        }
        return UICollectionViewCell()
    }
}

extension TomorrowViewController: UICollectionViewDelegate {

}

extension TomorrowViewController: CLLocationManagerDelegate {
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

