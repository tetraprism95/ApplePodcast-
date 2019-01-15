//
//  PodcastCell.swift
//  Podcast
//
//  Created by Nuri Chun on 8/3/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import SDWebImage


class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "Episodes: \(podcast.trackCount ?? 0)"
            
//            guard let urlString = podcast.artworkUrl600 else { return }
//            print("URL:", urlS)
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
        
//
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                print("Fetching image data")
//
//                guard let data = data else { return }
//
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//
//            }.resume()
            
            podcastImageView.sd_setImage(with: url, completed: nil) 
        }
    }
    
    
}
