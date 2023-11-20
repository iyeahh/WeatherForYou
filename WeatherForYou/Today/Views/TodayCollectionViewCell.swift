//
//  HourlyWeatherCollectionViewCell.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import UIKit

final class TodayCollectionViewCell: UICollectionViewCell {
    static let identifier = "TodayCollectionViewCell"

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()

    lazy var weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        return imageView
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),

            weatherImageView.widthAnchor.constraint(equalToConstant: 40),
            weatherImageView.heightAnchor.constraint(equalToConstant: 40),
            weatherImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),

            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 5)
        ])
    }
}
