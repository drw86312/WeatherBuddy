//
//  WeatherFeedViewController.swift
//  WeatherBuddy
//
//  Created by David Warner on 6/19/21.
//

import UIKit
import CoreLocation

enum SegueIdentifier: String {
    case toDetailViewController
}

enum ViewIdentifier: String {
    case feedCell = "weatherFeedCell"
    case feedHeader = "weatherFeedHeader"
    case feedFooter = "weatherFeedFooter"
}

class WeatherFeedViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    
    private let viewModel = WeatherFeedViewModel()
    private var cellModels: [WeatherFeedCellDisplayable] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()

        viewModel.delegate = self
        title = viewModel.pageTitle
        
        spinner.isHidden = false
        spinner.hidesWhenStopped = true

        // Attempt to load from cached coordinate on initial load
        guard let coordinate = viewModel.retrieveCachedCoordinate() else { return }
        viewModel.updateCoordinate(coordinate)
        viewModel.getLocationName(for: coordinate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              identifier == SegueIdentifier.toDetailViewController.rawValue,
              let model = sender as? WeatherFeedCellDisplayable,
              let viewController = segue.destination as? WeatherDetailViewController else {
            return
        }
        viewController.model = model
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        viewModel.updateLocation()
    }
    
    @objc func refreshData() {
        viewModel.fetchData()
    }
}

private extension WeatherFeedViewController {
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(UINib(nibName: "WeatherFeedCollectionCell", bundle: .main),
                                forCellWithReuseIdentifier: ViewIdentifier.feedCell.rawValue)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, point, env) -> Void in
            let pageIndex = Int(point.x / (self?.collectionView.frame.size.width ?? 1))
            self?.viewModel.updatePage(index: pageIndex)
        }
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func presentErrorAlert(error: Error) {
        // Would localize these strings in production app
        let alert = UIAlertController(title: "Oops, something went wrong",
                                      message: "Weather currently unavailable",
                                      preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}

extension WeatherFeedViewController: WeatherFeedViewModelDelegate {
    
    func didUpdateCellModels(models: [WeatherFeedCellDisplayable]) {
        cellModels = models
        collectionView.reloadData()
    }
    
    func didUpdateHeaderModel(model: WeatherFeedHeaderViewModel) {
        headerTitleLabel.text = model.city
    }
    
    func didUpdateFooterModel(model: WeatherFeedFooterViewModel) {
        pageControl.numberOfPages = model.numberOfPages
        pageControl.currentPage = model.currentPage
    }
    
    func didUpdatePage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    func didUpdateLoading(isLoading: Bool) {
        if isLoading {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didError(error: Error) {
        presentErrorAlert(error: error)
    }
}

extension WeatherFeedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueIdentifier.toDetailViewController.rawValue, sender: cellModels[safe: indexPath.row])
    }
}

extension WeatherFeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewIdentifier.feedCell.rawValue, for: indexPath) as? WeatherFeedCollectionCell else {
            assertionFailure("WeatherFeedCollectionCell not found at indexPath \(indexPath)")
            return UICollectionViewCell()
        }
        cell.update(with: cellModels[safe: indexPath.row])
        return cell
    }
}

