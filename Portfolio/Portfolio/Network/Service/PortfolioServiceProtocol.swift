//
//  PortfolioServiceProtocol.swift
//  Portfolio
//

import RxSwift

protocol PortfolioServiceProtocol {
    func fetchPortfolio() -> Single<PortfolioResponse>
}
