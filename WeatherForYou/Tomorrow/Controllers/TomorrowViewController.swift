//
//  TomorrowViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import UIKit
import CoreLocation

class TomorrowViewController: UIViewController {

    let weatherDataManager = WeatherDataManager.shared
    let screenHeight: CGFloat = UIScreen.main.bounds.height

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var tomorrowDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var tomorrowCollectionView: UICollectionView = {
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

    lazy var dayAfterTomorrowDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var dayAfterTomorrowCollectionView: UICollectionView = {
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
        setBackground(color1: UIColor.weatherTheme.base.0, color2: UIColor.weatherTheme.base.1)
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .cityName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .tomorrowWeatherList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dayAfterTomorrowWeatherList, object: nil)
    }

    private func setupLayout() {
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
    
    private func setupCollectionView() {
        tomorrowCollectionView.dataSource = self
        tomorrowCollectionView.delegate = self
        tomorrowCollectionView.showsHorizontalScrollIndicator = false

        dayAfterTomorrowCollectionView.dataSource = self
        dayAfterTomorrowCollectionView.delegate = self
        dayAfterTomorrowCollectionView.showsHorizontalScrollIndicator = false
    }

    private func registerCollecionViewCell() {
        tomorrowCollectionView.register(TomorrowCollectionViewCell.self, forCellWithReuseIdentifier: TomorrowCollectionViewCell.identifier)
        dayAfterTomorrowCollectionView.register(DayAfterTomorrowCollectionViewCell.self, forCellWithReuseIdentifier: DayAfterTomorrowCollectionViewCell.identifier)
    }

    @objc func configureUI() {
        DispatchQueue.main.async {
            self.locationLabel.text = self.weatherDataManager.cityName

            self.tomorrowDateLabel.text = Date.tomorrowAndNextDayToString().0
            self.dayAfterTomorrowDateLabel.text = Date.tomorrowAndNextDayToString().1
        }
    }

    @objc func reloadData() {
        DispatchQueue.main.async {
            self.tomorrowCollectionView.reloadData()
            self.dayAfterTomorrowCollectionView.reloadData()
        }
    }

    private func setBackground(color1: UIColor, color2: UIColor) {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TomorrowViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tomorrowCollectionView {
            return weatherDataManager.tomorrowWeatherList.count
        } else if collectionView == dayAfterTomorrowCollectionView {
            return weatherDataManager.dayAfterTomorrowWeatherList.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == tomorrowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TomorrowCollectionViewCell.identifier, for: indexPath) as! TomorrowCollectionViewCell

            if let date = weatherDataManager.tomorrowWeatherList[indexPath.row].dateText {
                cell.timeLabel.text = Date.dateToHours(date: date)
            }

            if let temp = weatherDataManager.tomorrowWeatherList[indexPath.row].tempInfo?.temp {
                let roundedTemp = round(temp)
                cell.temperatureLabel.text = "\(Int(roundedTemp))°C"
            }

            if let icon = weatherDataManager.tomorrowWeatherList[indexPath.row].weather?.first?.icon {
                cell.weatherImageView.image = weatherDataManager.setImage(iconString: icon)
            }

            return cell

        } else if collectionView == dayAfterTomorrowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayAfterTomorrowCollectionViewCell.identifier, for: indexPath) as! DayAfterTomorrowCollectionViewCell

            if let date = weatherDataManager.dayAfterTomorrowWeatherList[indexPath.row].dateText {
                cell.timeLabel.text = Date.dateToHours(date: date)
            }

            if let temp = weatherDataManager.dayAfterTomorrowWeatherList[indexPath.row].tempInfo?.temp {
                let roundedTemp = round(temp)
                cell.temperatureLabel.text = "\(Int(roundedTemp))°C"
            }

            if let icon = weatherDataManager.dayAfterTomorrowWeatherList[indexPath.row].weather?.first?.icon {
                cell.weatherImageView.image = weatherDataManager.setImage(iconString: icon)
            }

            return cell
        }
        return UICollectionViewCell()
    }
}

extension TomorrowViewController: UICollectionViewDelegate {

}


