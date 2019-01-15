//
//  RSSFeed.swift
//  Podcast
//
//  Created by Nuri Chun on 8/4/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {
    
    // for = "=>"
    // Just deleted feed => feed.iTunes?.iTunesImage?.attributes?.href
    
    func toEpisodes() -> [Episode] {
        
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        var episodes = [Episode]()
        
        items?.forEach({ (feedItem) in
            
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }

            episodes.append(episode)
        })
        
        return episodes
    }
}
