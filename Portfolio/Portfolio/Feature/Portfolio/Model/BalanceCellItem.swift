//
//  BalanceCellItem.swift
//  Portfolio
//

import UIKit

struct BalanceCellItem {
    let netValueText: String
    let pnlText: String
    let pnlPercentageText: String
    let pnlColor: UIColor
}

extension BalanceCellItem {
    init(balance: Balance) {
        netValueText = String(format: "Current balance: %.2f", balance.netValue)
        
        let isGain = balance.pnl >= 0
        let prefix = isGain ? "Profit: +" : "Loss: −"
        let prefixPerc = isGain ? "Profit (perc): +" : "Loss: −"
        
        pnlColor = isGain ? .systemGreen : .systemRed
        pnlText = String(format: "%@%.2f", prefix, abs(balance.pnl))
        pnlPercentageText = String(format: "%@%.2f%%", prefixPerc, abs(balance.pnlPercentage))
    }
}
