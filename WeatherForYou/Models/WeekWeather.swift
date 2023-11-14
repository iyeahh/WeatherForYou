//
//  WeekWeather.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/9/23.
//

import Foundation

// MARK: - WeekWeather
struct WeekWeather: Codable {
    let response: Response?
}

// MARK: - Response
struct Response: Codable {
    let body: Body?
}

// MARK: - Body
struct Body: Codable {
    let items: Items?
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let taMin3, taMax3: Int?
    let taMin4, taMax4: Int?
    let taMin5, taMax5: Int?
    let taMin6, taMax6: Int?
    let taMin7, taMax7: Int?
    let taMin8, taMax8: Int?
    let taMin9, taMax9: Int?
    let taMin10, taMax10: Int?
}
