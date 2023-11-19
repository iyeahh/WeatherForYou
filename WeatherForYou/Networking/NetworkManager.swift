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

    func fetchCurrentWeather(lat: String, lon: String, completion: @escaping (Result<CurrentWeather, NetworkError>) -> Void) {

        guard let url = makeURL(path: NetworkConfig.URLPath.weather.rawValue, lat: lat, lon: lon) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        performRequest(request: request, completion: completion)
    }

    func fetch3DaysForecast(lat: String, lon: String, completion: @escaping (Result<Forecast, NetworkError>) -> Void) {

        guard let url = makeURL(path: NetworkConfig.URLPath.forecast.rawValue, lat: lat, lon: lon) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        performRequest(request: request, completion: completion)
    }

    func fetchWeekWeather(location: String, date: String, completion: @escaping (Result<WeekWeather, NetworkError>) -> Void) {

        guard let url = makeURL(path: NetworkConfig.URLPath.weekWeather.rawValue, location: location, date: date) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        performRequest(request: request, completion: completion)
    }

    func fetchWeekWeatherImageAndRain(location: String, date: String, completion: @escaping (Result<WeekWeatherImage, NetworkError>) -> Void) {
        guard let url = makeURL(path: NetworkConfig.URLPath.weekWeatherImage.rawValue, location: location, date: date) else { return }
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

    private func makeURL(path: String, location: String, date: String) -> URL? {

        var urlComponents = URLComponents(string: "\(NetworkConfig.weekWeatherURL)/\(path)")

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY_2") as? String else { return nil }

        let numOfRowsQuery = URLQueryItem(name: "numOfRows", value: "10")
        let pageNoQuery = URLQueryItem(name: "pageNo", value: "1")
        let serviceKeyQuery = URLQueryItem(name: "serviceKey", value: apiKey)
        let dataTypeQuery = URLQueryItem(name: "dataType", value: "JSON")
        let regIdQuery = URLQueryItem(name: "regId", value: location)
        let dateQuery = URLQueryItem(name: "tmFc", value: date)

        urlComponents?.queryItems = [numOfRowsQuery, pageNoQuery, serviceKeyQuery, dataTypeQuery, regIdQuery, dateQuery]

        return urlComponents?.url
    }
}

