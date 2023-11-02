//
//  NetworkManager.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import Foundation
import CoreLocation

enum NetworkError: String, Error {
    case networkingError
    case dataError
    case parseError
}

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    typealias NetworkCompletion = (Result<TodayWeather?, NetworkError>) -> Void

    func fetchWeather(dateString: String, timeString: String, xCoordinate: String, yCoordinate: String, completion: @escaping NetworkCompletion) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        let urlString = "\(NetworkConfig.baseURL)?serviceKey=\(apiKey)&\(NetworkConfig.baseParam)&base_time=\(timeString)&base_date=\(dateString)&nx=\(xCoordinate)&ny=\(yCoordinate)"
        print(urlString)

        performRequest(with: urlString) { result in
            completion(result)
        }
    }

    func performRequest(with urlString: String, completion: @escaping NetworkCompletion) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession(configuration: .default)

        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(.failure(.networkingError))
                return
            }

            guard let safeData = data else {
                completion(.failure(.dataError))
                return
            }

            if let weather = self.parseJSON(safeData) {
                completion(.success(weather))
            } else {
                completion(.failure(.parseError))
            }
        }
        task.resume()
    }

    func parseJSON(_ weatherData: Data) -> TodayWeather? {
        do {
            let decodedData = try JSONDecoder().decode(Weather.self, from: weatherData)
            let weather = decodedData.response.body.items.item[0]
            let todayWeather = TodayWeather(date: weather.baseDate, location: "서울", skyStatus: weather.category, temperature: weather.fcstValue)
            return todayWeather
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
