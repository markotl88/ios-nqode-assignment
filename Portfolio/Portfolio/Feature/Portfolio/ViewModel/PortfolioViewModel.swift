//
//  PortfolioViewModel.swift
//  Portfolio
//

import Foundation
import RxSwift
import RxCocoa

final class PortfolioViewModel {

    // MARK: - Private properties
    
    private let portfolioRelay = BehaviorRelay<Portfolio?>(value: nil)
    private var previousPositions: [Position] = []
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let isPausedRelay = BehaviorRelay<Bool>(value: false)
    
    private let service: PortfolioServiceProtocol
    private var pricingService: PricingSimulationService?
    private let disposeBag = DisposeBag()

    // MARK: - Public properties

    var portfolioItems: Driver<[PortfolioCellItem]> {
        return portfolioRelay
            .map { [weak self] currentPortfolio -> [PortfolioCellItem] in
                guard let portfolio = currentPortfolio else { return [] }

                var items: [PortfolioCellItem] = []
                items.append(.balance(BalanceCellItem(balance: portfolio.balance)))
                let previousPositions = self?.previousPositions ?? []
                let sortedPositions = portfolio.positions.sorted { $0.marketValue > $1.marketValue }
                let positionItems: [PortfolioCellItem] = sortedPositions.map { newPosition in
                    let oldPrice = previousPositions.first(where: { $0.instrument.ticker == newPosition.instrument.ticker })?.instrument.lastTradedPrice
                    return .position(PositionCellItem(position: newPosition, oldPrice: oldPrice))
                }
                items += positionItems
                return items
            }
            .asDriver(onErrorJustReturn: [])
    }
    var error: Driver<String> {
        return errorRelay.asDriver(onErrorJustReturn: "Unknown error")
    }
    var isPaused: Bool { isPausedRelay.value }
    var isLoading: Driver<Bool> {
        return isLoadingRelay.asDriver()
    }
    
    // MARK: - Initializer

    init(service: PortfolioServiceProtocol) {
        self.service = service
    }
    
    // MARK: - Public methods

    func fetchPortfolio() {
        isLoadingRelay.accept(true)

        service.fetchPortfolio()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let self else { return }

                    isLoadingRelay.accept(false)
                    let sorted = self.getSortedPortfolio(response.portfolio)
                    portfolioRelay.accept(sorted)
                    startLiveSimulation(from: response.portfolio)
                },
                onFailure: { [weak self] error in
                    guard let self else { return }

                    isLoadingRelay.accept(false)
                    errorRelay.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    func toggleSimulationState() {
        isPausedRelay.accept(!isPausedRelay.value)
    }

    // MARK: - Private methods

    private func getSortedPortfolio(_ portfolio: Portfolio) -> Portfolio {
        let sortedPositions = portfolio.positions.sorted {
            $0.marketValue > $1.marketValue
        }

        return Portfolio(
            balance: portfolio.balance,
            positions: sortedPositions
        )
    }

    private func startLiveSimulation(from portfolio: Portfolio) {
        self.pricingService = PricingSimulationService(positions: portfolio.positions)

        pricingService?
            .startLivePricing(isPaused: isPausedRelay.asObservable())
            .subscribe(onNext: { [weak self] updatedPositions in
                guard let self else { return }
                let netValue = updatedPositions.reduce(0) { $0 + $1.marketValue }
                let pnl = updatedPositions.reduce(0) { $0 + $1.pnl }
                let totalCost = updatedPositions.reduce(0) { $0 + $1.cost }
                let pnlPercentage = totalCost == 0 ? 0 : (pnl * 100) / totalCost

                let updatedBalance = Balance(
                    netValue: netValue,
                    pnl: pnl,
                    pnlPercentage: pnlPercentage
                )

                let sorted = updatedPositions.sorted { $0.marketValue > $1.marketValue }

                let updatedPortfolio = Portfolio(
                    balance: updatedBalance,
                    positions: sorted
                )

                previousPositions = portfolioRelay.value?.positions ?? []
                portfolioRelay.accept(updatedPortfolio)
            })
            .disposed(by: disposeBag)
    }
}
