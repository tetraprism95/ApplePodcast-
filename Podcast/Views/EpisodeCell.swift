//
//  EpisodeCellTableViewCell.swift
//  Podcast
//
//  Created by Nuri Chun on 8/4/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    
    var episode: Episode? {
        didSet {
            
            guard let episode = episode else { return }
            
            pubDateLabel.text = episode.pubDate.description
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            
            let officialPubDateFormat = dateFormatter.string(from: episode.pubDate)
            pubDateLabel.text = officialPubDateFormat
            
            let secureUrl = episode.imageUrl?.secureHttps()
            
            let url = URL(string: secureUrl ?? "")
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
}
