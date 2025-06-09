import Foundation

enum WeatherError: Error {
    case networkError
    case decodingError
    case cityNotFound
}

typealias ForecastResult = Result<[WeatherDayModel], WeatherError>
typealias ForecastCompletion = (ForecastResult) -> Void

protocol WeatherService: AnyObject {
    func getForecast(city: String, completion: @escaping ForecastCompletion)
}

final class WeatherServiceImpl: WeatherService {
    private let apiKey = "75f66cde2aa8450b83a174209251004"
    private let baseURL = "https://api.weatherapi.com/v1"
    private let session = URLSession.shared
    
    func getForecast(city: String, completion: @escaping ForecastCompletion) {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/forecast.json?key=\(apiKey)&q=\(encodedCity)&days=5&aqi=no&alerts=no") else {
            completion(.failure(.networkError))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    completion(.failure(.networkError))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.networkError))
                    return
                }
                
                print(String(data: data, encoding: .utf8) ?? "Не удалось преобразовать данные в строку")
                
                do {
                    let forecastResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    let forecastDays = forecastResponse.forecast.forecastday.map { day in
                        WeatherDayModel(
                            date: self.formatDate(day.date),
                            conditionText: day.day.condition.text,
                            iconUrl: "https:\(day.day.condition.icon.replacingOccurrences(of: "64x64", with: "128x128"))",
                            avgTemp: "\(Int(day.day.avgtemp_c))°C",
                            maxWind: "\(Int(day.day.maxwind_kph)) km/h",
                            humidity: "\(Int(day.day.avghumidity))%"
                        )
                    }
                    completion(.success(forecastDays))
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    completion(.failure(.decodingError))
                }
            }
        }
        task.resume()
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date).capitalized
        
        dateFormatter.dateFormat = "d MMMM"
        let formattedDate = dateFormatter.string(from: date)
        
        return "\(dayOfWeek), \(formattedDate)"
    }
}
