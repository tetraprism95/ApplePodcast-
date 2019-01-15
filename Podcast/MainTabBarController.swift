//
//  MainTabBarController.swift
//  Podcast
//
//  Created by Nuri Chun on 8/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    
    var minTopAnchorConstraint: NSLayoutConstraint!
    var maxTopAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailsView()
        
    }
    
    @objc func minimizePlayerDetailsView() {
        
        maxTopAnchorConstraint.isActive = false
        bottomConstraint.constant = view.frame.height
        minTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.tabBar.transform = .identity
                        self.playerDetailsView.maximizeStackView.alpha = 0
                        self.playerDetailsView.miniPlayerView.alpha = 1
        })
    }
    
    func maximizePlayerDetailsView(episode: Episode?, playlistEpisodes: [Episode] = []) {
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        playerDetailsView.playlistEpisodes = playlistEpisodes
        
        minTopAnchorConstraint.isActive = false
        maxTopAnchorConstraint.isActive = true
        maxTopAnchorConstraint.constant = 0
        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
                        self.playerDetailsView.maximizeStackView.alpha = 1
                        self.playerDetailsView.miniPlayerView.alpha = 0
        })
    }

    // MARK: - setupViewControllers()
    
    private func setupViewControllers() {
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        let layout = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        
        let favoritesNavController = setNavigationController(for: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites"))
        let searchNavController = setNavigationController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search"))
        let downloadsNavController = setNavigationController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads")) 
        
        viewControllers = [searchNavController, favoritesNavController, downloadsNavController]
    }
    
    private func setNavigationController(for viewController: UIViewController, title: String?, image: UIImage?) -> UIViewController {
        
        let viewController = viewController
        
        let navController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        return navController
    }
    
    var bottomConstraint: NSLayoutConstraint!

    private func setupPlayerDetailsView() {
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
    
        maxTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maxTopAnchorConstraint.isActive = true
        
        minTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//        minTopAnchorConstraint.isActive = false
        
        bottomConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomConstraint.isActive = true
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
}















