//
//  PlayerDetailsView+PanGesture.swift
//  Podcast
//
//  Created by Nuri Chun on 8/9/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

extension PlayerDetailsView {

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .changed {
            handlePanChanged(gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture)
        }
    }
    
    @objc func handlePanDismissal(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizeStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        } else if gesture.state == .ended {
            
            let translation = gesture.translation(in: superview)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                            self.maximizeStackView.transform = .identity
                            if translation.y > 75 {
                                UIApplication.mainTabBarController()?.minimizePlayerDetailsView()
                            }
            })
        }
    }

    fileprivate func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        miniPlayerView.alpha = 1 + translation.y / 250
        maximizeStackView.alpha = -translation.y / 250
    }
    
    fileprivate func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.transform = .identity
                        
                        if translation.y < -250 || velocity.y < -500.0 {
                            UIApplication.mainTabBarController()?.maximizePlayerDetailsView(episode: nil)
                        } else {
                            self.miniPlayerView.alpha = 1
                            self.maximizeStackView.alpha = 0
                        }
        })
    }
    
    @objc func handleTapMaximize() {
        UIApplication.mainTabBarController()?.maximizePlayerDetailsView(episode: nil)
    }
}
