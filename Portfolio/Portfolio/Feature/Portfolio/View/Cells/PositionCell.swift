//
//  PositionCell.swift
//  Portfolio
//

import UIKit

class PositionCell: UICollectionViewCell {
    static let reuseIdentifier = "PositionCell"
    
    // MARK: - Constants
    
    private enum Constants {
        static let animationDuration: CGFloat = 0.5
        static let animationColorAlpha: CGFloat = 0.3
    }
    
    // MARK: - Private properties

    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let sharesCountLabel = UILabel()
    private let marketValueLabel = UILabel()
    private let costLabel = UILabel()
    private let pnlLabel = UILabel()
    private let differenceLabel = UILabel()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        nameLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.font = .systemFont(ofSize: 14)
        sharesCountLabel.font = .systemFont(ofSize: 14)
        costLabel.font = .systemFont(ofSize: 14)
        marketValueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        differenceLabel.font = .systemFont(ofSize: 14)
        pnlLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        differenceLabel.textAlignment = .right
        pnlLabel.textAlignment = .right
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, priceLabel, sharesCountLabel, costLabel, marketValueLabel, differenceLabel, pnlLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentView.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods

    func configure(with item: PositionCellItem) {
        nameLabel.text = item.title
        priceLabel.text = item.priceText
        sharesCountLabel.text = item.sharesText
        marketValueLabel.text = item.marketValueText
        pnlLabel.textColor = item.pnlColor
        pnlLabel.text = item.pnlText
        
        if let diffText = item.differenceText {
            differenceLabel.text = diffText
            differenceLabel.textColor = item.differenceColor
        } else {
            differenceLabel.text = nil
        }
        
        if let color = item.differenceColor {
            animateChange(withColor: color)
        }
    }
    
    func animateChange(withColor color: UIColor) {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.contentView.backgroundColor = color.withAlphaComponent(Constants.animationColorAlpha)
        }) { _ in
            UIView.animate(withDuration: Constants.animationDuration) {
                self.contentView.backgroundColor = .secondarySystemBackground
            }
        }
    }
}
