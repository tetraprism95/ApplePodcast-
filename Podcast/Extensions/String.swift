//
//  String.swift
//  Podcast
//
//  Created by Nuri Chun on 8/4/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation

extension String {
    
    func secureHttps() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
