//
//  DayAfterTomorrowCollectionViewCell.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/9/23.
//

import UIKit

class DayAfterTomorrowCollectionViewCell: UICollectionViewCell {
    static let identifier = "DayAfterTomorrowCollectionViewCell"

    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "10:00"
        label.font = UIFont.systemFont(ofSize: 10)
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
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(temperatureLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

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
