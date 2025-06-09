import UIKit

final class WeatherView: UIViewController {
    
    private var viewModel = WeatherViewModel()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Прогноз погоды"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .black
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Введите город"
        bar.backgroundImage = UIImage()
        bar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        return bar
    }()
    
    private let selectedCityLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let table: UITableView = {
        let table = UITableView()
        table.register(WeatherDayCell.self, forCellReuseIdentifier: WeatherDayCell.identifier)
        table.backgroundColor = .white
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        return table
    }()
    
    private let loading: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        table.dataSource = self
        searchBar.delegate = self
        addSubviews()
        setupConstraints()
        bindViewModel()
    }
    

    private func addSubviews() {
        [
            label,
            searchBar,
            selectedCityLabel,
            table,
            loading
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            
            selectedCityLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            selectedCityLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            selectedCityLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            table.topAnchor.constraint(equalTo: selectedCityLabel.bottomAnchor, constant: 12),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.loading.startAnimating() : self?.loading.stopAnimating()
            }
        }
        
        viewModel.onCityUpdated = { [weak self] cityName in
            self?.selectedCityLabel.text = "Город: \(cityName)"
        }

        viewModel.onForecastUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
            
        viewModel.onErrorOccurred = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message: message)
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


extension WeatherView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        viewModel.fetchWeather(for: city)
        searchBar.resignFirstResponder()
    }
}

extension WeatherView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.forecast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: WeatherDayCell.identifier, for: indexPath) as? WeatherDayCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.forecast[indexPath.row])
        return cell
    }
}
