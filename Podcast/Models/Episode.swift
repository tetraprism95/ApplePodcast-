//
//  Episode.swift
//  Podcast
//
//  Created by Nuri Chun on 8/4/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable {
    
    let title: String
    let pubDate: Date
    let description: String
    let author: String
    let streamUrl: String
    
    var fileUrl: String?
    var imageUrl: String?
    
    init(feedItem: RSSFeedItem) {
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
}
