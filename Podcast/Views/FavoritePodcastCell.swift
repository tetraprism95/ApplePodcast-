//
//  FavoritePodcastCell.swift
//  Podcast
//
//  Created by Nuri Chun on 8/12/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    var podcast: Podcast? {
        didSet {
            nameLabel.text = podcast?.trackName
            artistNameLabel.text = podcast?.artistName
            
            guard let url = URL(string: podcast?.artworkUrl600 ?? "") else { return }
            imageView.sd_setImage(with: url)
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "appicon"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "PewNews"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        return label
    }()
    
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.text = "PewDiePie"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setupUICell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - FUNCTIONS

extension FavoritePodcastCell {
    
    fileprivate func setupUICell() {
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
}






















