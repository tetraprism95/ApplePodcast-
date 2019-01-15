//
//  EpisodesController.swift
//  Podcast
//
//  Created by Nuri Chun on 8/3/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    // MARK: - Properties
    
    let cellId = "cellId"
    var episodes = [Episode]()
    var podcast: Podcast? {
        didSet {
            guard let trackName = podcast?.trackName else { return }
            navigationItem.title = trackName
        
            fetchEpisodes()
        }
    }
    
    // MARK: - viewDidLoad()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavBarItems()
    }
}

// MARK: - setupNavigationBarButtons(), setupTableView()

extension EpisodesController {
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func setupNavBarItems() {
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts() // return array of podcasts
        let hasSaved = savedPodcasts.index(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName}) != nil
        if hasSaved {
            // setup heart icon
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorites))]
        }
    }
    
    @objc func handleFetchSavedPodcast() {
        
        // How to fetch data from our PodcastObject
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return }
//        let podcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast] else { return }

        savedPodcasts.forEach { (podcast) in
            print("Podcast: \(podcast.trackName ?? "")")
        }
    }
    
    @objc func handleSaveFavorites() {
        print("favorite podcast saved to UserDefaults")
        guard let podcast = self.podcast else { return }
        
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    }
    
    fileprivate func showBadgeHighlight() {
            UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
        }
    
    fileprivate func showBadgeHighlightDownloaded() {
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = "Added"
    }
}

// MARK: - fetchEpisodes()

extension EpisodesController {
    
    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension EpisodesController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        
        let episode = episodes[indexPath.row]
        cell.episode = episode

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = self.episodes[indexPath.row]
        UIApplication.mainTabBarController()?.maximizePlayerDetailsView(episode: episode, playlistEpisodes: self.episodes)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty == true ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let episode = episodes[indexPath.row]
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_,_) in
            
            UserDefaults.standard.downloadEpisode(episode: episode)
            APIService.shared.downloadEpisode(episode: episode)
            self.showBadgeHighlightDownloaded()
        }
        return [downloadAction]
    }
}

















