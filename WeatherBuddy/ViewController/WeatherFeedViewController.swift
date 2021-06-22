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
    private var cellModels: [DailySnapshot] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set page title
        title = Strings.pageTitle

        // Setup UICollectionView
        configureCollectionView()

        // Make WeatherFeedViewController the delegate of the ViewModel
        viewModel.delegate = self

        // Attempt to load data with cached coordinate on initial launch
        viewModel.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              identifier == SegueIdentifier.toDetailViewController.rawValue,
              let model = sender as? DailySnapshot,
              let viewController = segue.destination as? WeatherDetailViewController else {
            return
        }
        viewController.model = model
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        viewModel.updateLocation()
    }
    
    // Pull to refresh
    @objc private func refreshData() {
        viewModel.reloadData()
    }
    
    private func presentErrorAlert(error: Error) {
        let alert = UIAlertController(title: Strings.alertTitle,
                                      message: Strings.alertMessage,
                                      preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: CollectionView Configuration
private extension WeatherFeedViewController {
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(UINib(nibName: String(describing: WeatherFeedCollectionCell.self), bundle: .main),
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
        
        /*
        // I don't believe you can use UIScrollViewDelegate with Compositional Layout
         to calculate the current page, so using visibleItemsInvalidationHandler
        */
        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, point, env) -> Void in
            let pageIndex = Int(point.x / (self?.collectionView.frame.size.width ?? 1))
            self?.viewModel.updatePage(index: pageIndex)
        }
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: ViewModel
extension WeatherFeedViewController: WeatherFeedViewModelDelegate {
    
    func didUpdateCellModels(models: [DailySnapshot]) {
        cellModels = models
        collectionView.reloadData()
    }
    
    func didUpdateHeaderModel(model: WeatherFeedHeaderViewModel) {
        headerTitleLabel.text = model.city
    }
    
    func didUpdateFooterModel(model: WeatherFeedFooterViewModel) {
        pageControl.numberOfPages = model.numberOfPages
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

// MARK: UICollectionViewDelegate
extension WeatherFeedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueIdentifier.toDetailViewController.rawValue, sender: cellModels[safe: indexPath.row])
    }
}

// MARK: UICollectionViewDataSource
extension WeatherFeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewIdentifier.feedCell.rawValue, for: indexPath) as? WeatherFeedCollectionCell else {
            // Using assertion failure here to identify critical bugs in development
            assertionFailure("WeatherFeedCollectionCell not found at indexPath \(indexPath)")
            return UICollectionViewCell()
        }
        cell.update(with: cellModels[safe: indexPath.row])
        return cell
    }
}

// MARK: Localized Strings
private extension WeatherFeedViewController {
    // In production, I would localize these strings for different languages
    struct Strings {
        static let pageTitle = NSLocalizedString("Weather Buddy", comment: "Title for weather feed view controller")
        static let alertTitle = NSLocalizedString("Oops, something went wrong", comment: "Title for error alert")
        static let alertMessage = NSLocalizedString("Weather currently unavailable", comment: "Message for error alert")
    }
}


