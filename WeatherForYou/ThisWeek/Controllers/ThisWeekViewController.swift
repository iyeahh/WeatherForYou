//
//  ThisWeekViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import UIKit
import CoreLocation

class ThisWeekViewController: UIViewController {

    let weatherDataManager = WeatherDataManager.shared

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()

    lazy var thisWeekTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupLayout()
        setupTableView()
        registerTableView()
        configureUI()
        setBackground(color1: UIColor.weatherTheme.base.1, color2: UIColor.weatherTheme.base.0)
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .weekWeatherList, object: nil)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),

            thisWeekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            thisWeekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            thisWeekTableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 50),
            thisWeekTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func setupTableView() {
        thisWeekTableView.delegate = self
        thisWeekTableView.dataSource = self
        thisWeekTableView.rowHeight = 70
        thisWeekTableView.separatorStyle = .none
    }

    private func registerTableView() {
        thisWeekTableView.register(WeekWeatherTableViewCell.self, forCellReuseIdentifier: WeekWeatherTableViewCell.identifier)
    }

    @objc func configureUI() {
        DispatchQueue.main.async {
            self.locationLabel.text = self.weatherDataManager.cityName
            self.thisWeekTableView.reloadData()
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
}

extension ThisWeekViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataManager.weekWeatherArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeekWeatherTableViewCell.identifier, for: indexPath) as! WeekWeatherTableViewCell

        let weekWeather = weatherDataManager.weekWeatherArray[indexPath.row]

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
