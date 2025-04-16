//
//  PortfolioResponse.swift
//  Portfolio
//

import Foundation

struct PortfolioResponse: Decodable {
    let portfolio: Portfolio
}

struct Portfolio: Decodable {
    let balance: Balance
    let positions: [Position]
}

struct Balance: Decodable {
    let netValue: Double
    let pnl: Double
    let pnlPercentage: Double
}

struct Position: Decodable {
    let instrument: Instrument
    let quantity: Double
    let averagePrice: Double
    let cost: Double
    let marketValue: Double
    let pnl: Double
    let pnlPercentage: Double
}

struct Instrument: Decodable {
    let ticker: String
    let name: String
    let exchange: String
    let currency: Currency
    var lastTradedPrice: Double
}

enum Currency: String, Decodable {
    case usd = "USD"
    case gbp = "GBP"
    case eur = "EUR"
}
