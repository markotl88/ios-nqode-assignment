# ios-nqode-assignment
nQode Portfolio assessment task

The assessment has been completed, including the bonus task.

The PricingSimulationService handles positions and balance calculation/updates. It seems that initial (JSON) value for netValue in the balance might not be accurate, but I assumed this was not critical.

The simulation interval has been increased to 5 seconds (It could be adjusted in the same file).

NetworkManager is a simple networking layer I typically use in similar projects — this time implemented as RxNetworkManager using RxSwift.

RxSwift 6.9.0 was added via Swift Package Manager.

A basic dummy unit test was included for PortfolioViewModel.

Since I don’t have much experience with RxSwift, I used some analogies with Combine. I hope that’s acceptable.

Marko Stajic
