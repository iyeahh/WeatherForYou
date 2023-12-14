//
//  TomorrowViewController.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import UIKit
import CoreLocation

class TomorrowViewController: UIViewController {

    let viewModel = TomorrowViewModel()

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
            self.locationLabel.text = self.viewModel.cityName

            self.tomorrowDateLabel.text = self.viewModel.tomorrowDateString
            self.dayAfterTomorrowDateLabel.text = self.viewModel.dayAfterTomorrowDateString

            self.setBackground(color1: UIColor.weatherTheme.base.0, color2: UIColor.weatherTheme.base.1)
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
}

extension TomorrowViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tomorrowCollectionView {
            return viewModel.tomorrowWeatherListCount
        } else if collectionView == dayAfterTomorrowCollectionView {
            return viewModel.dayAfterTomorrowWeatherListCount
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == tomorrowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TomorrowCollectionViewCell.identifier, for: indexPath) as! TomorrowCollectionViewCell

            cell.timeLabel.text = viewModel.getTimeString(index: indexPath.row)
            cell.temperatureLabel.text = viewModel.getTempString(index: indexPath.row)
            cell.weatherImageView.image = viewModel.getIconImageWithColor(index: indexPath.row)

            return cell

        } else if collectionView == dayAfterTomorrowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayAfterTomorrowCollectionViewCell.identifier, for: indexPath) as! DayAfterTomorrowCollectionViewCell

            cell.timeLabel.text = viewModel.getDayAfterTomorrowTimeString(index: indexPath.row)
            cell.temperatureLabel.text = viewModel.getDayAfterTomorrowTimeString(index: indexPath.row)
            cell.weatherImageView.image = viewModel.getDayAfterTomorrowIconImageWithColor(index: indexPath.row)

            return cell
        }
        return UICollectionViewCell()
    }
}

extension TomorrowViewController: UICollectionViewDelegate {

}


