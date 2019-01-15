//
//  PodcastSearchController.swift
//  Podcast
//
//  Created by Nuri Chun on 8/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    
    let cellId = "cellId"
    var podcasts = [Podcast]()
    var timer: Timer?
    var searchText: String?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }

    private func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func createView(withLabel label: UILabel, activityIndicatorView indicator: UIActivityIndicatorView?) -> UIView {
        
        let viewRect = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let theView = UIView(frame: viewRect)
        theView.translatesAutoresizingMaskIntoConstraints = false
        
        var theLabel = UILabel()
        theLabel = label
        theLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var activityIndicatorView = UIActivityIndicatorView()
        guard let indicator = indicator else { return UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))}
        activityIndicatorView = indicator
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(theView)
        theView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        theView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        theView.addSubview(theLabel)
        theLabel.centerXAnchor.constraint(equalTo: theView.centerXAnchor).isActive = true
        theLabel.centerYAnchor.constraint(equalTo: theView.centerYAnchor).isActive = true
        
        theView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: theView.centerXAnchor).isActive = true
        activityIndicatorView.topAnchor.constraint(equalTo: theLabel.bottomAnchor, constant: 12).isActive = true
        
        return theView
    }
}



// MARK: - UISearchBarDelegate

extension PodcastsSearchController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        self.searchText = searchText
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            APIService.shared.fetchPodcast(searchText: searchText) { (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
}

// MARK: - UITableViewControllerDelegate & DataSource

extension PodcastsSearchController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
//
//        cell.textLabel?.text = "\(podcast.trackName ?? "") \n\(podcast.artistName ?? "")"
//        cell.textLabel?.numberOfLines = 0
//        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
//
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episodesController = EpisodesController()
        let podcast = podcasts[indexPath.row]
        episodesController.podcast = podcast
        
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let activityIndicatorView = UIActivityIndicatorView()
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        if searchText?.isEmpty == false {
            label.text = "Searching..."
            activityIndicatorView.color = .darkGray
            activityIndicatorView.startAnimating()

        } else if searchText?.isEmpty == true || searchText == nil {
            label.text = "Please Enter A Search Term."
        }
        return createView(withLabel: label, activityIndicatorView: activityIndicatorView)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
}














