//
//  PortfolioViewController.swift
//  Portfolio
//

import UIKit
import RxSwift
import RxCocoa

final class PortfolioViewController: UIViewController {

    // MARK: - Private properties

    private let viewModel: PortfolioViewModel
    private var collectionView: UICollectionView!
    private let disposeBag = DisposeBag()

    private var currentPositions: [PositionCellItem] = []
    private var playPauseButton: UIBarButtonItem!
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Initializer

    init(viewModel: PortfolioViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Portfolio"

        setupPlayPauseButton()
        setupCollectionView()
        setupLoadingView()
        bindViewModel()
        viewModel.fetchPortfolio()
    }

    // MARK: - Private methods

    private func setupPlayPauseButton() {
        playPauseButton = UIBarButtonItem(title: "Pause", style: .plain, target: self, action: #selector(toggleSimulation))
        navigationItem.rightBarButtonItem = playPauseButton
    }

    @objc private func toggleSimulation() {
        viewModel.toggleSimulationState()
        playPauseButton.title = viewModel.isPaused ? "Play" : "Pause"
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.isHidden = true
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(PositionCell.self, forCellWithReuseIdentifier: PositionCell.reuseIdentifier)
        collectionView.register(BalanceCell.self, forCellWithReuseIdentifier: BalanceCell.reuseIdentifier)
        view.addSubview(collectionView)
    }

    private func setupLoadingView() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
    }

    private func bindViewModel() {
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                self.loadingIndicator.isHidden = !isLoading
                isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
                self.collectionView.isHidden = isLoading
            })
            .disposed(by: disposeBag)

        viewModel.portfolioItems
            .drive(onNext: { [weak self] newItems in
                guard let self else { return }

                let newPositions = newItems.compactMap {
                    if case let .position(item) = $0 { return item } else { return nil }
                }

                let oldPositions = self.currentPositions
                self.currentPositions = newPositions

                self.collectionView.performBatchUpdates {
                    for (index, item) in newItems.enumerated() {
                        let indexPath = IndexPath(item: index, section: 0)

                        switch item {
                        case .balance(let balanceItem):
                            if let cell = self.collectionView.cellForItem(at: indexPath) as? BalanceCell {
                                cell.configure(with: balanceItem)
                            }

                        case .position(let newItem):
                            if let oldIndex = oldPositions.firstIndex(where: { $0.id == newItem.id }) {
                                let from = IndexPath(item: oldIndex + 1, section: 0)
                                let to = IndexPath(item: index, section: 0)

                                if from != to {
                                    self.collectionView.moveItem(at: from, to: to)
                                }

                                if let cell = self.collectionView.cellForItem(at: to) as? PositionCell {
                                    cell.configure(with: newItem)
                                } else {
                                    self.collectionView.reloadItems(at: [to])
                                }
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.portfolioItems
            .drive(collectionView.rx.items) { collectionView, index, item in
                let indexPath = IndexPath(item: index, section: 0)

                switch item {
                case .balance(let balanceItem):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BalanceCell.reuseIdentifier, for: indexPath) as! BalanceCell
                    cell.configure(with: balanceItem)
                    return cell

                case .position(let positionItem):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PositionCell.reuseIdentifier, for: indexPath) as! PositionCell
                    cell.configure(with: positionItem)
                    return cell
                }
            }
            .disposed(by: disposeBag)

        viewModel.error
            .drive(onNext: { [weak self] message in
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
