//
//  APIService.swift
//  Podcast
//
//  Created by Nuri Chun on 8/3/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}


extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    // singleton
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)

    static let shared = APIService()
    
    func downloadEpisode(episode: Episode) {
        
        print("Downloading episode using Alamofire at stream url: ", episode.streamUrl)
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title" : episode.title, "progress": progress.fractionCompleted])
        
            }.response { (response) in
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(response.destinationURL?.absoluteString ?? "", episode.title)
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo:  nil)
                
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.index(where: { $0.title == episode.title && $0.author == episode.author}) else { return }
                downloadedEpisodes[index].fileUrl = response.destinationURL?.absoluteString ?? ""
                
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
                } catch let err {
                    print("Failed to encode file url: ", err)
                }
        }
    }
    
    func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> ()) {
        
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: secureFeedUrl) else { return }
        
        DispatchQueue.global(qos: .background).async {
            
            let parser = FeedParser(URL: url)
            
            parser.parseAsync { (result) in
                if let error = result.error {
                    print("Unable to parse XML Feed:", error)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                
                let episodes = feed.toEpisodes()
                completion(episodes)
            }
        }
    }
    
    func fetchPodcast(searchText: String, completion: @escaping ([Podcast]) -> ()) {
        
        let url = "https://itunes.apple.com/search"
        let parameters = ["term" : searchText, "media" : "podcast"]

        Alamofire.request(url,
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseData { (dataResponse) in

                            if let error = dataResponse.error {
                                print("Failed to fetch yahoo", error )
                                return
                            }

                            guard let data = dataResponse.data else { return }

                            do {
                                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                                completion(searchResult.results) 
//                                self.podcasts = searchResult.results
//                                self.tableView.reloadData()

                            } catch let decodeError {
                                print("Failed to decode: ", decodeError)
                            }
        }
    }
    
}
