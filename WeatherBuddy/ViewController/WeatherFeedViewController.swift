//
//  WeatherFeedViewController.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/19/21.
//

import UIKit

enum SegueIdentifier: String {
    case toDetailViewController
}

enum CellIdentifier: String {
    case feedCell = "WeatherFeedCollectionCell"
}

class WeatherFeedViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    
    let viewModel = WeatherFeedViewModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.pageTitle
        configureCollectionView()
        
        WeatherService.getWeather()
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        
    }
}

private extension WeatherFeedViewController {
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(WeatherFeedCollectionCell.self, forCellWithReuseIdentifier: CellIdentifier.feedCell.rawValue)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        // Define Item Size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))

        // Create Item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Define Group Size
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))

        // Create Group
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [ item ])

        // Create Section
        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
        
//        let footerHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                      heightDimension: .absolute(50.0))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: footerHeaderSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top)
//        let footer = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: footerHeaderSize,
//            elementKind: UICollectionView.elementKindSectionFooter,
//            alignment: .bottom)
//        section.boundarySupplementaryItems = [header, footer]
    }
}

extension WeatherFeedViewController: UICollectionViewDelegate {
    
}

extension WeatherFeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.feedCell.rawValue, for: indexPath) as? WeatherFeedCollectionCell else {
            assertionFailure("WeatherFeedCollectionCell not found at indexPath \(indexPath)")
            return UICollectionViewCell()
        }
        return cell
    }
}

