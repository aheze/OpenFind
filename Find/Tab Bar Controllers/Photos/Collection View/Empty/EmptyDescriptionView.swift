//
//  EmptyDescriptionView.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class EmptyDescriptionView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerLabel: LTMorphingLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var currentDisplayedFilter = PhotoFilter.local
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EmptyDescriptionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        headerLabel.morphingEffect = .evaporate
    }
    
    func change(from previousFilter: PhotoFilter, to photoFilter: PhotoFilter) {
        if currentDisplayedFilter != photoFilter {
            let headerText: String
            let descriptionText: String
            var newImage: UIImage?
            var flipFromRight = false
            
            switch photoFilter {
            case .local:
                headerText = "Local"
                descriptionText = "Photos saved from Find will appear here"
                newImage = UIImage(named: "LocalPhotos")
                flipFromRight = true
            case .starred:
                headerText = "Starred"
                descriptionText = "Star the photos that you view the most"
                newImage = UIImage(named: "StarredPhotos")
                if previousFilter != .local {
                    flipFromRight = true
                }
            case .cached:
                headerText = "Cached"
                descriptionText = "Results will appear instantly when finding in cached photos"
                newImage = UIImage(named: "CachedPhotos")
                if previousFilter == .all {
                    flipFromRight = true
                }
            case .all:
                headerText = ""
                descriptionText = ""
                break
            }
            
            headerLabel.text = headerText
            
            descriptionLabel.fadeTransition(0.15)
            descriptionLabel.text = descriptionText
            
            UIView.transition(with: imageView, duration: 0.3, options: flipFromRight ? .transitionFlipFromRight : .transitionFlipFromLeft) {
                self.imageView.image = newImage
            }
            currentDisplayedFilter = photoFilter
        }
    }
}
