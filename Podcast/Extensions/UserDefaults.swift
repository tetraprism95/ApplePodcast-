//
//  UserDefaults.swift
//  Podcast
//
//  Created by Nuri Chun on 8/18/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    
    func deleteEpisode(episode: Episode) {
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (ep) -> Bool in
            return ep.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey) 
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func savedPodcasts() -> [Podcast] {
        
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return [] }
        
        return savedPodcasts
    }
    
    func deletePodcast(podcast: Podcast) {
        
        let podcasts = savedPodcasts()
        let filteredPodcastList = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcastList)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }
    
    func downloadEpisode(episode: Episode) {
        
        do {
            var episodes = downloadedEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
            
        } catch let encodeError {
            print("Unable to encode: \(encodeError)")
        }
     }
    
    func downloadedEpisodes() -> [Episode] {

        do {
            guard let data = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodeKey) else  { return [] }
            let episodes = try JSONDecoder().decode([Episode].self, from: data)
            return episodes
            
        } catch let decodeErr {
            print("Decoding Error: \(decodeErr)")
        }
        
        return []
    }
}










