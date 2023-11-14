//
//  ColorTheme.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/14/23.
//

import UIKit

extension UIColor {
    static let weatherTheme = WeatherTheme()
}

struct WeatherTheme {
    let sun: (UIColor, UIColor) = (#colorLiteral(red: 0.9304228425, green: 0.6922988892, blue: 0.4968693256, alpha: 1), #colorLiteral(red: 0.8107313514, green: 0.3261011243, blue: 0.4575048685, alpha: 1))
    let cloud: (UIColor, UIColor) = (#colorLiteral(red: 0.7741769552, green: 0.829197824, blue: 0.5121616721, alpha: 1), #colorLiteral(red: 0.3986772895, green: 0.5372212529, blue: 0.3082891405, alpha: 1))
    let rain: (UIColor, UIColor) = (#colorLiteral(red: 0.4369112849, green: 0.6447789073, blue: 0.7945023775, alpha: 1), #colorLiteral(red: 0.2854483128, green: 0.3308053613, blue: 0.5405058861, alpha: 1))
    let snow: (UIColor, UIColor) = (#colorLiteral(red: 0.9677416682, green: 0.9727140069, blue: 0.9898334146, alpha: 1), #colorLiteral(red: 0.9677416682, green: 0.9727140069, blue: 0.9898334146, alpha: 1))
    let base: (UIColor, UIColor) = (#colorLiteral(red: 0.6723831892, green: 0.5646241307, blue: 0.7415238023, alpha: 1), #colorLiteral(red: 0.2927551866, green: 0.2779331803, blue: 0.5755700469, alpha: 1))
    let baseReversed: (UIColor, UIColor) = (#colorLiteral(red: 0.2927551866, green: 0.2779331803, blue: 0.5755700469, alpha: 1), #colorLiteral(red: 0.6723831892, green: 0.5646241307, blue: 0.7415238023, alpha: 1))
}
