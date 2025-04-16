//
//  BalanceCell.swift
//  Portfolio
//

import UIKit

final class BalanceCell: UICollectionViewCell {
    static let reuseIdentifier = "BalanceCell"
    
    // MARK: - Private properties

    private let netValueLabel = UILabel()
    private let pnlLabel = UILabel()
    private let pnlPercentageLabel = UILabel()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        netValueLabel.font = .boldSystemFont(ofSize: 24)
        pnlLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        pnlPercentageLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        let stack = UIStackView(arrangedSubviews: [netValueLabel, pnlLabel, pnlPercentageLabel])
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods

    func configure(with item: BalanceCellItem) {
        netValueLabel.text = item.netValueText
        pnlLabel.textColor = item.pnlColor
        pnlLabel.text = item.pnlText
        pnlPercentageLabel.textColor = item.pnlColor
        pnlPercentageLabel.text = item.pnlPercentageText
    }
}
