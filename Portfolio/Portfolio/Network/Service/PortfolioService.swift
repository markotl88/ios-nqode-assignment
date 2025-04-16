//
//  PortfolioService.swift
//  Portfolio
//

import Foundation
import RxSwift

final class PortfolioService: PortfolioServiceProtocol {
    private let networkManager: RxNetworkManagerProtocol
    private let urlString = "https://dummyjson.com/c/60b7-70a6-4ee3-bae8"
    
    init(networkManager: RxNetworkManagerProtocol = RxNetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchPortfolio() -> Single<PortfolioResponse> {
        guard let url = URL(string: urlString) else {
            return .error(NetworkingError.invalidURL)
        }
        
        return networkManager.get(url: url, headers: nil)
    }
}
