import Foundation

final class WeatherViewModel {

    private let weatherService: WeatherService
    private(set) var forecast: [WeatherDayModel] = []

    var onForecastUpdated: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    var onCityUpdated: ((String) -> Void)?

    init(weatherService: WeatherService = WeatherServiceImpl()) {
        self.weatherService = weatherService
    }

    func fetchWeather(for city: String) {
        onLoadingChanged?(true)
        weatherService.getForecast(city: city) { [weak self] result in
            guard let self = self else { return }
            self.onLoadingChanged?(false)
            self.onCityUpdated?(city.capitalized)
            switch result {
            case .success(let forecast):
                self.forecast = forecast
                self.onForecastUpdated?()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }

    private func handleError(_ error: WeatherError) {
        let message: String
        switch error {
        case .cityNotFound:
            message = "Город не найден"
        case .decodingError:
            message = "Ошибка обработки данных"
        case .networkError:
            message = "Проблемы с интернет-соединением"
        }
        onErrorOccurred?(message)
    }
}
