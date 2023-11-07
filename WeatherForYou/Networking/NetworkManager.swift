//
//  NetworkManager.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/1/23.
//

import Foundation
import CoreLocation

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    func fetchWeather(lat: String, lon: String, completion: @escaping (Result<CurrentWeather, NetworkError>) -> Void) {

        guard let url = makeURL(path: NetworkConfig.URLPath.weather.rawValue, lat: lat, lon: lon) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        performRequest(request: request, completion: completion)
    }

    func fetchForecast(lat: String, lon: String, completion: @escaping (Result<Forecast, NetworkError>) -> Void) {

        guard let url = makeURL(path: NetworkConfig.URLPath.forecast.rawValue, lat: lat, lon: lon) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        performRequest(request: request, completion: completion)
    }

    func performRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.networkingError))
                return
            }

            guard let safeData = data else {
                completion(.failure(.dataError))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: safeData)
                completion(.success(decodedData))
                return
            } catch {
                completion(.failure(.parseError))
                return
            }
        }.resume()
    }
}

extension NetworkManager {

    private func makeURL(path: String, lat: String, lon: String) -> URL? {

        var urlComponents = URLComponents(string: "\(NetworkConfig.baseURL)/\(path)")

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return nil }

        let latQuery = URLQueryItem(name: "lat", value: lat)
        let lonQuery = URLQueryItem(name: "lon", value: lon)
        let appIdQuery = URLQueryItem(name: "appid", value: apiKey)
        let langQuery = URLQueryItem(name: "lang", value: "kr")
        let unitsQuery = URLQueryItem(name: "units", value: "metric")

        urlComponents?.queryItems = [latQuery, lonQuery, appIdQuery, langQuery, unitsQuery]

        return urlComponents?.url
    }
}

