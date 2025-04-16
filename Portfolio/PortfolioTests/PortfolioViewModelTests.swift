//
//  Untitled.swift
//  Portfolio
//

import XCTest
import RxBlocking
import RxTest
import RxSwift

@testable import Portfolio

final class PortfolioViewModelTests: XCTestCase {

    func testPortfolioItemsEmittedAfterFetch() throws {
        // Given
        let balance = Balance(netValue: 1000, pnl: 100, pnlPercentage: 10)
        let position = Position(
            instrument: .init(
                ticker: "AAPL",
                name: "Apple Inc.",
                exchange: "NASDAQ",
                currency: .usd,
                lastTradedPrice: 150
            ),
            quantity: 5,
            averagePrice: 120,
            cost: 600,
            marketValue: 750,
            pnl: 150,
            pnlPercentage: 25
        )
        let portfolio = Portfolio(balance: balance, positions: [position])
        let mockService = MockPortfolioService(result: .success(PortfolioResponse(portfolio: portfolio)))
        
        let viewModel = PortfolioViewModel(service: mockService)

        // When
        viewModel.fetchPortfolio()

        // Then
        let items = try viewModel.portfolioItems
            .toBlocking(timeout: 2)
            .first()

        XCTAssertEqual(items?.count, 2)

        if case let .balance(balanceItem)? = items?.first {
            XCTAssertEqual(balanceItem.netValueText, "Current balance: 1000.00")
        }

        if case let .position(positionItem)? = items?.last {
            XCTAssertEqual(positionItem.title, "AAPL — Apple Inc.")
            XCTAssertEqual(positionItem.marketValueText, "Market value: 750.00 USD")
        }
    }
}
