//
//  TodayViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 10/27/23.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController {

    let viewModel = TodayViewModel()

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
        setupLayout()
        setupCollectionView()
        registerCollecionViewCell()
        configureUI()
        viewModel.onDataUpdated = { [weak self] in
            self?.configureUI()
        }
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
            guard self.viewModel.validWeatherData() else { return }

            self.dateLabel.textColor = self.viewModel.textColor
            self.locationLabel.textColor = self.viewModel.textColor
            self.tempRangeLabel.textColor = self.viewModel.textColor
            self.temperatureLabel.textColor = self.viewModel.textColor

            self.locationLabel.text = self.viewModel.cityName

            self.dateLabel.text = self.viewModel.dateString
            self.tempRangeLabel.text = self.viewModel.feelsLikeTemp
            self.temperatureLabel.text = self.viewModel.currentTemp
            self.weatherImageView.image = self.viewModel.weatherImage

            let (color1, color2) = self.viewModel.backgroundColor 
            self.setBackground(color1: color1, color2: color2)

            self.todayCollectionView.reloadData()
        }
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.todayWeatherListCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayCollectionViewCell.identifier, for: indexPath) as! TodayCollectionViewCell

        cell.temperatureLabel.textColor = viewModel.textColor
        cell.timeLabel.textColor = viewModel.textColor
        cell.timeLabel.text = viewModel.getTimeString(index: indexPath.row)
        cell.temperatureLabel.text = viewModel.getTempString(index: indexPath.row)
        cell.weatherImageView.image = viewModel.getIconImageWithColor(index: indexPath.row)

        return cell
    }
}

extension TodayViewController: UICollectionViewDelegate {

}
