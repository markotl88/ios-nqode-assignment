//
//  PricingSimulationService.swift
//  Portfolio
//

import Foundation
import RxSwift

final class PricingSimulationService {
    private enum Constants {
        static let simulationInterval: Int = 5
    }
    
    private let originalPositions: [Position]
    
    init(positions: [Position]) {
        self.originalPositions = positions
    }
    
    func startLivePricing(isPaused: Observable<Bool>) -> Observable<[Position]> {
        return Observable<Int>.interval(.seconds(Constants.simulationInterval), scheduler: MainScheduler.instance)
            .withLatestFrom(isPaused) { (_, paused) in paused }
            .filter { !$0 }
            .map { [originalPositions] _ in
                let updatedPositions = originalPositions.map { position in
                    var instrument = position.instrument
                    let basePrice = instrument.lastTradedPrice
                    let randomFactor = Double.random(in: -0.1...0.1)
                    let newPrice = basePrice * (1 + randomFactor)
                    instrument.lastTradedPrice = newPrice
                    
                    let marketValue = position.quantity * newPrice
                    let pnl = marketValue - position.cost
                    let pnlPercentage = position.cost == 0 ? 0 : (pnl * 100) / position.cost
                
                    return Position(instrument: instrument,
                                    quantity: position.quantity,
                                    averagePrice: position.averagePrice,
                                    cost: position.cost,
                                    marketValue: marketValue,
                                    pnl: pnl,
                                    pnlPercentage: pnlPercentage)
                }
                let sortedPositions = updatedPositions.sorted(by: { $0.marketValue > $1.marketValue })
                sortedPositions.enumerated().forEach { index, position in
                    debugPrint("\(index+1) Name: \(position.instrument.ticker) - Market Value: \(position.marketValue)")
                }
                return sortedPositions
            }
    }
}
