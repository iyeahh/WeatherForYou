//
//  Date+.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/19/23.
//

import Foundation

extension Date {
    static func currentDateToString() -> String {
        let nowDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"

        return dateFormatter.string(from: nowDate)
    }

    static func dateToHours(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        let convertDate = dateFormatter.date(from: date)

        let dateFormatterToHours = DateFormatter()
        dateFormatterToHours.dateFormat = "HH시"

        return dateFormatterToHours.string(from: convertDate!)
    }

    static func tomorrowAndNextDayToString() -> (String, String) {
        let nowDate = Date()
        var tomorrowDate = Date()
        var afterDayTomorrowDate = Date()

        if let nextDay = Calendar.current.date(byAdding: .hour, value: 24, to: nowDate) {
            tomorrowDate = nextDay
        }
        if let dayAfterTomorrow = Calendar.current.date(byAdding: .hour, value: 48, to: nowDate) {
            afterDayTomorrowDate = dayAfterTomorrow
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"

        return (dateFormatter.string(from: tomorrowDate), dateFormatter.string(from: afterDayTomorrowDate))
    }

    static func currentDataForWeek() -> String {
        let nowDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "HH"
        
        let after6DateFormatter = DateFormatter()
        after6DateFormatter.dateFormat = "yyyyMMdd0600"

        if Int(dateFormatter.string(from: nowDate))! < 06 {
            guard let date = Calendar.current.date(byAdding: .day, value: -1, to: nowDate) else { return "" }
            return after6DateFormatter.string(from: date)
        } else {
            return after6DateFormatter.string(from: nowDate)
        }
    }

    static func dateFormatterForWeek(afterHours: Int) -> String {
        let nowDate = Date()
        var afterHoursDate = Date()

        if let date = Calendar.current.date(byAdding: .hour, value: afterHours, to: nowDate) {
            afterHoursDate = date
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "MM/dd(EEE)"

        return dateFormatter.string(from: afterHoursDate)
    }
}
