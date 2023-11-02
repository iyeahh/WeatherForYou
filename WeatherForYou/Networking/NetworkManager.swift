//
//  NetworkManager.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import Foundation

enum NetworkError: String, Error {
    case networkingError
    case dataError
    case parseError
}

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    typealias NetworkCompletion = (Result<Response?, NetworkError>) -> Void

    func fetchWeather(dateString: String, xCoordinate: Int, yCoordinate: Int, completion: @escaping NetworkCompletion) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        let urlString = "\(NetworkConfig.baseURL)?serviceKey=\(apiKey)&\(NetworkConfig.baseParam)&base_date=\(dateString)&nx=\(xCoordinate)&ny=\(yCoordinate)"
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
                print("Parse 실행")
                completion(.success(weather))
            } else {
                print("Parse 실패")
                completion(.failure(.parseError))
            }
        }
        task.resume()
    }

    func parseJSON(_ weatherData: Data) -> Response? {
        do {
            let weatherData = try JSONDecoder().decode(Weather.self, from: weatherData)
            return weatherData.response
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
