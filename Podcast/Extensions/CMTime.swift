//
//  CMTime.swift
//  Podcast
//
//  Created by Nuri Chun on 8/6/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation
import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        
        let totalTime = Int(CMTimeGetSeconds(self))
        let seconds = totalTime % 60
        let minutes = totalTime / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
