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

    func fetchWeather(xCoordinate: Double, yCoordinate: Double, completion: @escaping NetworkCompletion) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        let urlString = "\(NetworkConfig.baseURL)&lat=\(xCoordinate)&lon=\(yCoordinate)&appid=\(apiKey)"
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
                print("에러있음")
                return
            }

            guard let safeData = data else {
                completion(.failure(.dataError))
                print("데이터에러")
                return
            }

            if let weather = self.parseJSON(safeData) {
                completion(.success(weather))
            } else {
                completion(.failure(.parseError))
                print("파싱에러")
            }
        }
        task.resume()
    }

    func parseJSON(_ weatherData: Data) -> TodayWeather? {
        do {
            let decodedData = try JSONDecoder().decode(CurrentWeather.self, from: weatherData)
            guard let weather = decodedData.main else { return nil }
            let todayWeather = TodayWeather(tempMin: weather.tempMin ?? 0.0, tempMax: weather.tempMax ?? 0.0, temperature: weather.temp ?? 0.0)
            return todayWeather
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
