//
//  WeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by barış çelik on 24.12.2021.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    private let cellDegreeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let cellDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .semibold)
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
        contentView.addSubview(cellDegreeLabel)
        contentView.addSubview(cellDateLabel)
        contentView.addSubview(cellImageView)
        let labelSize: CGFloat = 30
        cellDegreeLabel.frame = CGRect(x: 0,
                                 y: 5,
                                 width: contentView.frame.size.width,
                                 height: labelSize)
        cellDateLabel.frame = CGRect(x: 0,
                                     y: labelSize + 10,
                                     width: contentView.frame.size.width,
                                     height: labelSize)
        let imageHeight: CGFloat = contentView.frame.size.height - 2 * labelSize - 15
        cellImageView.frame = CGRect(x: 0,
                                     y: 2 * labelSize + 15,
                                     width: contentView.frame.size.width,
                                     height: imageHeight)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
        cellDegreeLabel.text = nil
    }
    
    private func setGradientBackground() {
        gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]
        gradient.locations = [0.0, 0.7]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = contentView.bounds
        contentView.layer.addSublayer(gradient)
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: WeatherViewModel) {
        cellDegreeLabel.text = "\(viewModel.airTemp)° C"
        cellDateLabel.text = viewModel.time
        switch viewModel.dayTime {
        case .day:
            gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]
        case.night:
            gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        case .afternoon:
            gradient.colors = [UIColor.white.cgColor, UIColor.systemBlue.cgColor]
        }
        cellImageView.image = UIImage(systemName: viewModel.weatherType.rawValue)
    }
    
}
