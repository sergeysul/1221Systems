import UIKit

final class WeatherDayCell: UITableViewCell {
    
    static let identifier = "WeatherDayCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let weatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let windLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let metricsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillProportionally
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupShadow()
        addSubviews()
        setupConstraints()
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }
    
    private func addSubviews() {
        metricsStack.addArrangedSubview(windLabel)
        metricsStack.addArrangedSubview(humidityLabel)
        
        contentView.addSubview(containerView)
        
        [
            dayLabel,
            weatherIcon,
            descriptionLabel,
            tempLabel,
            metricsStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
    }
    
    func configure(with model: WeatherDayModel) {
        
        dayLabel.text = model.date
        descriptionLabel.text = model.conditionText
        tempLabel.text = model.avgTemp
        windLabel.text = "🌬️ \(model.maxWind)"
        humidityLabel.text = "💧 \(model.humidity)"
        
        weatherIcon.image = nil
        if let url = URL(string: model.iconUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.weatherIcon.image = image
                    }
                }
            }.resume()
        }
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
    
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            weatherIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            weatherIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            weatherIcon.widthAnchor.constraint(equalToConstant: 40),
            weatherIcon.heightAnchor.constraint(equalToConstant: 40),
  
            dayLabel.topAnchor.constraint(equalTo: weatherIcon.topAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 12),
            dayLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            
            tempLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            tempLabel.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            
            metricsStack.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 8),
            metricsStack.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            metricsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
}
