//
//  MockPortfolioService.swift
//  Portfolio
//

import XCTest
import RxBlocking
import RxTest
import RxSwift

@testable import Portfolio

final class MockPortfolioService: PortfolioServiceProtocol {
    private let result: Result<PortfolioResponse, Error>

    init(result: Result<PortfolioResponse, Error>) {
        self.result = result
    }

    func fetchPortfolio() -> Single<PortfolioResponse> {
        switch result {
        case .success(let portfolio):
            return .just(portfolio)
        case .failure(let error):
            return .error(error)
        }
    }
}

extension MockPortfolioService {
    convenience init(portfolio: Portfolio) {
        self.init(result: .success(PortfolioResponse(portfolio: portfolio)))
    }
}
