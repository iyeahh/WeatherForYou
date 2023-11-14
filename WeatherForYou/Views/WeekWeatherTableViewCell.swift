//
//  WeekWeatherTableViewCell.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/9/23.
//

import UIKit

class WeekWeatherTableViewCell: UITableViewCell {
    static let identifier = "WeekWeatherTableViewCell"

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "11/15(수)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()

    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sun")
        return imageView
    }()

    let tempMinMaxLabel: UILabel = {
        let label = UILabel()
        label.text = "18도"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()

    let rainLabel: UILabel = {
        let label = UILabel()
        label.text = "11/15(수)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(tempMinMaxLabel)
        contentView.addSubview(rainLabel)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        tempMinMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        rainLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            weatherImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            weatherImageView.widthAnchor.constraint(equalToConstant: 30),
            weatherImageView.heightAnchor.constraint(equalToConstant: 30),
            weatherImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            tempMinMaxLabel.leadingAnchor.constraint(equalTo: weatherImageView.trailingAnchor, constant: 50),
            tempMinMaxLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            tempMinMaxLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            rainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rainLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            rainLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
