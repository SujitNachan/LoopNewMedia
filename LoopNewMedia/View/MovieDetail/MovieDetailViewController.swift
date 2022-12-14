//
//  MovieDetailViewController.swift
//  LoopNewMedia
//
//  Created by  on 03/11/22.
//

import UIKit

enum MovieDetailViewSections: Int, CaseIterable {
    case poster
    case overView
    case director
    case actors
    case keyFacts
}

struct MovieSectionDetailViewModel {
    let movieViewModel: MovieViewModel?
    let overView: String?
    let director: TableViewCellWithCollectionViewViewModel?
    let actors: [TableViewCellWithCollectionViewViewModel]
    let keyFacts: KeyFactsTableViewCellConfigurator
}

class MovieDetailViewController: UIViewController {
    private var interactor: MovieDetailViewInteractorInterface?
    private var movieTableView: UITableView?
    private var movieSectionDetailViewModel: MovieSectionDetailViewModel?
    private let bookmarkButton = UIButton(type: .custom)
    
    init(interactor: MovieDetailViewInteractorInterface) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
//        navigationItem.title = "Detail"
        setupNavigationBar()
        setupUI()
        interactor?.getSectionsData()
        updateBookmarkImage()
    }
    
    private func setupNavigationBar() {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "Close"), for: .normal)
        closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        let closeButtonItem = UIBarButtonItem(customView: closeButton)
        closeButtonItem.customView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        closeButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bookmarkButton.setImage(UIImage(named: "BookmarkBlack"), for: .normal)
        bookmarkButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        bookmarkButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 26, bottom: 5, right: 20)
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonClicked), for: .touchUpInside)
        let bookmarkButtonItem = UIBarButtonItem(customView: bookmarkButton)
        bookmarkButtonItem.customView?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bookmarkButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.navigationItem.setRightBarButtonItems([closeButtonItem, bookmarkButtonItem], animated: false)
        
    }
    
    private func setupUI() {
        let tableViewFrame = CGRect(origin: CGPoint(x: 0, y: 0 ), size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height - (self.navigationController?.navigationBar.bounds.height ?? 0)))
        movieTableView = UITableView(frame: tableViewFrame, style: .grouped)
        movieTableView?.separatorStyle = .none
        if let movieTableView = movieTableView {
            self.view.addSubview(movieTableView)
        }
        movieTableView?.backgroundColor = .clear
        movieTableView?.delegate = self
        movieTableView?.dataSource = self
        movieTableView?.register(MoviePosterTitleTableViewCell.self)
        movieTableView?.register(MovieOverviewTableViewCell.self)
        movieTableView?.register(TableViewCellWithCollectionView.self)
        movieTableView?.register(KeyFactsTableViewCell.self)
    }
    
    @objc private func closeButtonClicked() {
        self.dismiss(animated: true)
    }
    
    @objc private func bookmarkButtonClicked() {
        if let movieViewModel = movieSectionDetailViewModel?.movieViewModel {
            interactor?.bookmarkMovie(movieViewModel)
        }
    }
    
    private func updateBookmarkImage() {
        if let id = movieSectionDetailViewModel?.movieViewModel?.id {
            bookmarkButton.setImage(UIImage(named: UserDefaultDataManager.shared.retriveBookMarks().contains(id) ? "BookmarkFill" : "BookmarkBlack"), for: .normal)
        }
    }
}

extension MovieDetailViewController: MovieDetailViewControllerInterface {
    func updateBookmarkButton(_ movieViewModel: MovieViewModel) {
        UserDefaultDataManager.shared.retriveBookMarks().contains(movieViewModel.id) ? UserDefaultDataManager.shared.removeBookmark(id: movieViewModel.id) : UserDefaultDataManager.shared.addBookmark(id: movieViewModel.id)
        updateBookmarkImage()
    }
    
    func updateSectionsData(_ movieSectionDetailViewModel: MovieSectionDetailViewModel) {
        self.movieSectionDetailViewModel = movieSectionDetailViewModel
        self.movieTableView?.reloadData()
    }
    
    func showActivityIndicator() {
    }
    
    func hideActivityIndicator() {
    }
    
    func showAlertView(message: String) {
        showAlertViewWithStyle(title: "Error", message: message, actionTitles: ["Ok"], handler: [])
    }
}


extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MovieDetailViewSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemSize = CGSize(width: 114, height: 164)
        switch indexPath.section {
        case MovieDetailViewSections.poster.rawValue:
            let moviePosterCell: MoviePosterTitleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            moviePosterCell.cellData = self.movieSectionDetailViewModel?.movieViewModel
            return moviePosterCell
            
        case MovieDetailViewSections.director.rawValue:
            let directorCell: TableViewCellWithCollectionView = tableView.dequeueReusableCell(for: indexPath)
            guard let director = self.movieSectionDetailViewModel?.director else { return directorCell }
            directorCell.configuation = TableViewCellWithCollectionViewConfigurator(cellData: [director], footerSize: .zero, itemSize: itemSize)
            return directorCell
            
        case MovieDetailViewSections.actors.rawValue:
            let actorCell: TableViewCellWithCollectionView = tableView.dequeueReusableCell(for: indexPath)
            actorCell.configuation = TableViewCellWithCollectionViewConfigurator(cellData: self.movieSectionDetailViewModel?.actors, footerSize: .zero, itemSize: itemSize)
            return actorCell
            
        case MovieDetailViewSections.keyFacts.rawValue:
            let keyFactsCell: KeyFactsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            keyFactsCell.configuration = self.movieSectionDetailViewModel?.keyFacts
            return keyFactsCell
            
        default:
            let overViewCell: MovieOverviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            overViewCell.cellData = movieSectionDetailViewModel?.overView
            return overViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        switch section {
        case MovieDetailViewSections.overView.rawValue:
            title = "Overview"
        case MovieDetailViewSections.director.rawValue:
            title = "Director"
        case MovieDetailViewSections.actors.rawValue:
            title = "Actors"
        case MovieDetailViewSections.keyFacts.rawValue:
            title = "Key Facts"
        default:
            return nil
        }
        let headerWithLabel = HeaderViewWithLabel(title: title)
        return headerWithLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == MovieDetailViewSections.poster.rawValue ? 0 : 40
    }
}
