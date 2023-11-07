//
//  NetworkError.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/7/23.
//

import Foundation

enum NetworkError: String, Error {
    case networkingError
    case dataError
    case parseError
}
