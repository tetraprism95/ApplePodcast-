//
//  PlayerDetailsView.swift
//  Podcast
//
//  Created by Nuri Chun on 8/5/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    // MARK: - Properties
    
    fileprivate let scaleTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
 
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    var episode: Episode! {
        didSet {
            
            episodeTitleLabel.text = episode.title
            miniEpisodeTitleLabel.text = episode.title
            
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            setupAudioSession()
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl?.secureHttps() ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                
                let image = self.episodeImageView.image ?? UIImage()
                
                let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (_) -> UIImage in
                    return image
                })
            
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
        }
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizeStackView: UIStackView!
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniEpisodeTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            miniPlayPauseButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        }
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
            miniFastForwardButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) 
        }
    }
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5.0
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = self.scaleTransform
        }
    }
    
    @IBOutlet weak var currentPlayerSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel! {
        didSet {
            episodeTitleLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func handleCurrentPlayerSliderAction(_ sender: Any) {
        
        let percentage = currentPlayerSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, 1)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        
        let fifteenSeconds = CMTimeMake(delta, 1)
        let currenTime = player.currentTime()
        let seekTime = CMTimeAdd(currenTime, fifteenSeconds)
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }

    @IBAction func dismissButton(_ sender: Any) {
        UIApplication.mainTabBarController()?.minimizePlayerDetailsView()
    }


    // MARK: - awakeFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControler()
        setupGestures()
        setupInterruptionObserver()
        playerPeriodicTimeObserver()
        playerBoundaryTimeObserver()
    }
    
    fileprivate func setupInterruptionObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSessionInterruptionType.began.rawValue {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                
            }
        }
    }
    
    fileprivate func setupRemoteControler() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.setupElapsedTime(playbackRate: 1)
            
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupElapsedTime(playbackRate: 0)
            
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.handlePlayPause()
            
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    
    var playlistEpisodes = [Episode]()
    
    @objc func handleNextTrack() {
        
        if playlistEpisodes.count == 0 {
            return
        }
        
        let currentIndex = playlistEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentIndex else { return }
        
        let nextEpisode: Episode
        
        if index == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        
        self.episode = nextEpisode
    }
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)
        }
    }

    @objc func handlePreviousTrack() {
        
        if playlistEpisodes.count == 0 {
            return
        }
        
        let currentIndex = playlistEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentIndex else { return }
        let previousEpisode: Episode
        let playlistEpisodesCount = playlistEpisodes.count - 1
        
        if index == 0 {
            previousEpisode = playlistEpisodes[playlistEpisodesCount]
        } else {
            previousEpisode = playlistEpisodes[index - 1]
        }
        
        self.episode = previousEpisode
    }
    
    fileprivate func setupElapsedTime(playbackRate: Float) {
        
        let elapsedTime = player.currentTime()
        let elapsedTimeInSeconds = CMTimeGetSeconds(elapsedTime)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTimeInSeconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
     }
    
    fileprivate func setupAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let saveError {
            print("Could not persist the audio after closing of the application: ", saveError)
        }
        
    }

    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        maximizeStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanDismissal)))
    }
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    // MARK: - functions: playEpisode(), enlargeEpisodeImageView(), playerPeriodicTimeObserver(), playerBoundaryTimeObserver()
    
    fileprivate func setupNowPlayingInfo() {
        
        var playingInfo = [String : Any]()
        playingInfo[MPMediaItemPropertyTitle] = episode.title
        playingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    fileprivate func playEpisode() {
 
        
        if episode.fileUrl != nil {
            playEpisodeUsingFileUrl()
        } else {
            guard let url = URL(string: episode.streamUrl) else { return }
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }
    
    fileprivate func playEpisodeUsingFileUrl() {
        
        guard let fileUrl = URL(string: episode.fileUrl ?? "") else { return }
        let fileName = fileUrl.lastPathComponent
        
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        trueLocation.appendPathComponent(fileName)
        
        let playerItem = AVPlayerItem(url: trueLocation)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    fileprivate func playerPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            
            self?.currentTimeLabel.text = time.toDisplayString()
            let totalTime = self?.player.currentItem?.duration
            self?.totalTimeLabel.text = totalTime?.toDisplayString()
            self?.updatePlayerSlider()
        }
    }
    
    fileprivate func updatePlayerSlider() {
        let currentTIme = CMTimeGetSeconds(player.currentTime())
        let totalTime = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        let percentage = currentTIme / totalTime
        self.currentPlayerSlider.value = Float(percentage)
    }
    
    fileprivate func playerBoundaryTimeObserver() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupLockScreenDuration() {
        
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.episodeImageView.transform = self.scaleTransform
        })
    }
}


























