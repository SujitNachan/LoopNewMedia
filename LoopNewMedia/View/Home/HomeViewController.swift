//
//  ViewController.swift
//  LoopNewMedia
//
//  Created by  on 31/10/22.
//

import UIKit

enum HomeViewSections: Int, CaseIterable {
    case searchButton
    case yourFavorites
    case ourStaff
}

class HomeViewController: UIViewController {
    private var movieTableView: UITableView?
    var interactor: HomeViewInteractorInterface?
    private var staffPicks: [StaffPicksViewModel] = []
    private var yourFavoriteMovies: [TableViewCellWithCollectionViewViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        interactor?.fetchStaffPicks()
        interactor?.fetchMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        movieTableView = UITableView(frame: self.view.bounds, style: .grouped)
        movieTableView?.separatorStyle = .none
        if let movieTableView = movieTableView {
            self.view.addSubview(movieTableView)
        }
        movieTableView?.backgroundColor = .clear
        movieTableView?.delegate = self
        movieTableView?.dataSource = self
        movieTableView?.register(StaffPicksTableViewCell.self)
        movieTableView?.register(TableViewCellWithCollectionView.self)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeViewSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case HomeViewSections.searchButton.rawValue:
            return 0
        case HomeViewSections.ourStaff.rawValue:
            return self.staffPicks.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case HomeViewSections.ourStaff.rawValue:
            let staffCell: StaffPicksTableViewCell =  tableView.dequeueReusableCell(for: indexPath)
            staffCell.celldata = self.staffPicks[indexPath.row]
            staffCell.bookmarkHandler = { [unowned self] in
                self.interactor?.bookmarkStaffPicks(at: indexPath.row)
            }
            return staffCell
            
        default:
            let movieCell: TableViewCellWithCollectionView = tableView.dequeueReusableCell(for: indexPath)
            let itemSize = CGSize(width: 196, height: 284)
            movieCell.configuation = TableViewCellWithCollectionViewConfigurator(cellData: self.yourFavoriteMovies, footerSize: itemSize, itemSize: itemSize)
            movieCell.didSelectHandler = { [unowned self] yourFavoriteMovie in
                self.interactor?.movieDidSelect(yourFavoriteMovieViewModel: yourFavoriteMovie)
            }
            return movieCell
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == HomeViewSections.ourStaff.rawValue {
            interactor?.staffPicksDidSelect(staffPicksViewModel: staffPicks[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let boldfont = UIFont.SFProDisplay(.bold, size: 12) else {
            return nil
        }
        switch section {
        case HomeViewSections.searchButton.rawValue:
            let headerView = HeaderViewWithButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 48))
            headerView.searchButtonTapped = { [unowned self] in
                self.interactor?.routeToSearchScreen()
            }
            return headerView
            
        case HomeViewSections.yourFavorites.rawValue:
            let headerWithLabel = HeaderViewWithLabel(title: "YOUR FAVORITES", titleFont: UIFont.SFProDisplay(.regular, size: 12), textToChange: "FAVORITES", fontToChange: boldfont)
            return headerWithLabel
            
        case HomeViewSections.ourStaff.rawValue:
            let headerWithLabel = HeaderViewWithLabel(title: "OUR STAFF PICKS", titleColor: .white, titleFont: UIFont.SFProDisplay(.regular, size: 12), textToChange: "STAFF PICKS", fontToChange: boldfont)
            return headerWithLabel
            
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case HomeViewSections.searchButton.rawValue:
            return 48
        default:
            return 25
        }
    }
}

extension HomeViewController: HomeViewControllerInterface {
    func bookmarkStaffPicks(at index: Int) {
        self.movieTableView?.reloadRows(at: [IndexPath(row: index, section: HomeViewSections.ourStaff.rawValue)], with: .automatic)
    }
    
    func update(movies: [TableViewCellWithCollectionViewViewModel]) {
        self.yourFavoriteMovies = movies
        self.movieTableView?.reloadData()
    }
    
    func update(staffPicks: [StaffPicksViewModel]) {
        self.staffPicks = staffPicks
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
