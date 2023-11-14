//
//  WeekWeatherImage.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/14/23.
//

import Foundation

// MARK: - WeekWeatherImage
struct WeekWeatherImage: Codable {
    let response: ImageResponse?
}

// MARK: - Response
struct ImageResponse: Codable {
    let header: Header?
    let body: ImageBody?
}

// MARK: - Body
struct ImageBody: Codable {
    let dataType: String?
    let items: ImageItems?
    let pageNo, numOfRows, totalCount: Int?
}

// MARK: - Items
struct ImageItems: Codable {
    let item: [ImageItem]?
}

// MARK: - Item
struct ImageItem: Codable {
    let regID: String?
    let rnSt3Am, rnSt3Pm, rnSt4Am, rnSt4Pm: Int?
    let rnSt5Am, rnSt5Pm, rnSt6Am, rnSt6Pm: Int?
    let rnSt7Am, rnSt7Pm, rnSt8, rnSt9: Int?
    let rnSt10: Int?
    let wf3Am, wf3Pm, wf4Am, wf4Pm: String?
    let wf5Am, wf5Pm, wf6Am, wf6Pm: String?
    let wf7Am, wf7Pm, wf8, wf9: String?
    let wf10: String?

    enum CodingKeys: String, CodingKey {
        case regID = "regId"
        case rnSt3Am, rnSt3Pm, rnSt4Am, rnSt4Pm, rnSt5Am, rnSt5Pm, rnSt6Am, rnSt6Pm, rnSt7Am, rnSt7Pm, rnSt8, rnSt9, rnSt10, wf3Am, wf3Pm, wf4Am, wf4Pm, wf5Am, wf5Pm, wf6Am, wf6Pm, wf7Am, wf7Pm, wf8, wf9, wf10
    }
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String?
}
