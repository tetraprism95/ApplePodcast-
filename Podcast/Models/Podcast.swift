//
//  Podcast.swift
//  Podcast
//
//  Created by Nuri Chun on 8/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding { 
    
    func encode(with aCoder: NSCoder) {
        print("Trying to turn podcast into data")
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistName")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
        aCoder.encode(feedUrl ?? "", forKey: "feedUrl")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("Trying to turn data into podcast")
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistName") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKey") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedUrl") as? String 
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
