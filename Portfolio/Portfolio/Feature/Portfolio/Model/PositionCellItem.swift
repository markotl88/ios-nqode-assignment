//
//  PositionCellItem.swift
//  Portfolio
//

import UIKit

struct PositionCellItem {
    let id: String
    let title: String
    let priceText: String
    let sharesText: String
    let costText: String
    let marketValueText: String
    let pnlText: String
    let pnlColor: UIColor
    let currency: String
    let differenceText: String?
    let differenceColor: UIColor?
}

extension PositionCellItem {
    init(position: Position, oldPrice: Double? = nil) {
        id = position.instrument.ticker
        title = "\(position.instrument.ticker) — \(position.instrument.name)"
        priceText = String(format: "Price: %.2f %@", position.instrument.lastTradedPrice, position.instrument.currency.rawValue)
        sharesText = String(format: "Total shares: %.1f", position.quantity)
        costText = String(format: "Cost: %.2f", position.cost)
        marketValueText = String(format: "Market value: %.2f %@", position.marketValue, position.instrument.currency.rawValue)

        let isGain = position.pnl >= 0
        let pnlPrefix = isGain ? "Profit: +" : "Loss: −"
        pnlText = String(format: "%@%.2f (%.1f%%)", pnlPrefix, abs(position.pnl), abs(position.pnlPercentage))
        pnlColor = isGain ? .systemGreen : .systemRed
        currency = position.instrument.currency.rawValue

        if let oldPrice = oldPrice {
            debugPrint("Old price: \(String(describing: oldPrice))")
        } else {
            debugPrint("No old price")
        }
            
        if let oldPrice {
            let isPriceGain = position.instrument.lastTradedPrice >= oldPrice
            let diff = abs(position.instrument.lastTradedPrice - oldPrice)
            let prefix = isPriceGain ? "📈 Price increase: +" : "📉 Price decrease: −"
            differenceText = String(format: "%@%.2f", prefix, diff)
            differenceColor = isPriceGain ? .systemGreen : .systemRed
        } else {
            differenceText = "Price change not available"
            differenceColor = .secondaryLabel
        }
    }
}
