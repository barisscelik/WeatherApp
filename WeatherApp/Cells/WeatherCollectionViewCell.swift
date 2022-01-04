//
//  WeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by barış çelik on 24.12.2021.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    private let weatherMap: [DayTime : [String]] = {
        var dict = [DayTime : [String]]()
        dict[.day] = ["sun.and.horizon", "sun.haze", "sun.dust",
                      "cloud", "cloud.rain", "cloud.sun",
                      "cloud.sun.rain", "snowflake"]
        dict[.night] = ["snowflake", "wind.snow", "cloud.moon.rain",
                        "cloud.moon.bolt", "smoke", "moon.stars",
                        "moon"]
        
        return dict
    }()
    
    private let cellLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        return imageView
    }()
    
    private let gradient = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGradientBackground()
        contentView.addSubview(cellLabel)
        contentView.addSubview(cellImageView)
        let labelSize: CGFloat = 30
        cellLabel.frame = CGRect(x: 0,
                                 y: 5,
                                 width: contentView.frame.size.width,
                                 height: labelSize)
        cellImageView.frame = CGRect(x: 0,
                                     y: labelSize + 5,
                                     width: contentView.frame.size.width,
                                     height: contentView.frame.size.height - labelSize - 5)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setGradientBackground() {
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = contentView.bounds
        contentView.layer.addSublayer(gradient)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: WeatherViewModel) {
        cellLabel.text = viewModel.airTemp
        switch viewModel.dayTime {
        case .day:
            gradient.colors = [UIColor.white.cgColor, UIColor.systemBlue.cgColor]
        case.night:
            gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        }
        
        cellImageView.image = UIImage(systemName: (weatherMap[viewModel.dayTime]?.randomElement()) ?? "cloud")
    }
    
}
