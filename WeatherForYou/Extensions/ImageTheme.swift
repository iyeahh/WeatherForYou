//
//  ImageTheme.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/14/23.
//

import UIKit

extension UIImage {
    static let weatherImage = WeatherImage()
}

struct WeatherImage {
    let sun = UIImage(named: "sun")
    let cloudy = UIImage(named: "cloudy")
    let cloud = UIImage(named: "cloud")
    let cloudCloud = UIImage(named: "cloudcloud")
    let rain = UIImage(named: "rain")
    let storm = UIImage(named: "storm")
    let hail = UIImage(named: "hail")
    let fog = UIImage(named: "fog")
}

