//
//  UIApplication.swift
//  Podcast
//
//  Created by Nuri Chun on 8/9/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
