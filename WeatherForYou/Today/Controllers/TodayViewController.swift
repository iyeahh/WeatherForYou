//
//  TodayViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 10/27/23.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController {

    let weatherDataManager = WeatherDataManager.shared
    let screenHeight: CGFloat = UIScreen.main.bounds.height

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var tempRangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        return imageView
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var todayCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumLineSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupLayout()
        setupCollectionView()
        registerCollecionViewCell()
        configureUI()
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .cityName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .mainWeather, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .todayWeatherList, object: nil)
    }

    private func setupLayout() {
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

    private func setupCollectionView() {
        todayCollectionView.dataSource = self
        todayCollectionView.delegate = self
        todayCollectionView.showsHorizontalScrollIndicator = false
    }

    private func registerCollecionViewCell() {
        todayCollectionView.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: TodayCollectionViewCell.identifier)
    }

    private func setBackground(color1: UIColor, color2: UIColor) {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    @objc func configureUI () {
        DispatchQueue.main.async {
            guard let weather = self.weatherDataManager.mainWeater else { return }
            self.dateLabel.textColor = weather.textColor
            self.locationLabel.textColor = weather.textColor
            self.tempRangeLabel.textColor = weather.textColor
            self.temperatureLabel.textColor = weather.textColor

            self.locationLabel.text = self.weatherDataManager.cityName

            self.dateLabel.text = weather.dateString
            self.tempRangeLabel.text = "체감온도: \(Int(weather.feelsLikeTemp ?? 0.0))°C"
            self.temperatureLabel.text = "\(Int(weather.currentTemp ?? 0.0))°C"
            self.weatherImageView.image = weather.weatherImage

            let (color1, color2) = weather.backgrounColor ?? (UIColor.weatherTheme.base.0, UIColor.weatherTheme.base.1)
            self.setBackground(color1: color1, color2: color2)
            self.todayCollectionView.reloadData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDataManager.todayWeatherList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayCollectionViewCell.identifier, for: indexPath) as! TodayCollectionViewCell

        cell.temperatureLabel.textColor = weatherDataManager.mainWeater?.textColor
            cell.timeLabel.textColor = weatherDataManager.mainWeater?.textColor


        if let date = weatherDataManager.todayWeatherList[indexPath.row].dateText {
            cell.timeLabel.text = Date.dateToHours(date: date)
        }

        if let temp = weatherDataManager.todayWeatherList[indexPath.row].tempInfo?.temp {
            let roundedTemp = round(temp)
            cell.temperatureLabel.text = "\(Int(roundedTemp))°C"
        }

        if let textColor = weatherDataManager.mainWeater?.textColor {
            if let icon = weatherDataManager.todayWeatherList[indexPath.row].weather?.first?.icon {
                cell.weatherImageView.image = weatherDataManager.setImage(iconString: icon)?.withTintColor(textColor)
            }
        }

        return cell
    }
}

extension TodayViewController: UICollectionViewDelegate {

}
