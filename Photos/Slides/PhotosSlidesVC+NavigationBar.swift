//
//  PhotosSlidesVC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosSlidesViewController {
    func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = ""
        subtitleLabel.font = UIFont.systemFont(ofSize: 11)
        subtitleLabel.textAlignment = .center
        subtitleLabel.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        
        let width = max(titleLabel.frame.size.width, subtitleLabel.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 28)
        
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        
        navigationItem.titleView = stackView
        
        stackView.isAccessibilityElement = true
        stackView.accessibilityLabel = "Date taken"
        
        navigationTitleStackView = stackView
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        
        if let currentPhoto = model.slidesState?.currentPhoto {
            updateNavigationBarTitle(to: currentPhoto)
        }
    }
    
    func updateNavigationBarTitle(to photo: Photo) {
        if let dateCreated = photo.asset.creationDate {
            let dateAsString = dateCreated.convertDateToReadableString()
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "d MMM y"

            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.amSymbol = "AM"
            timeFormatter.pmSymbol = "PM"
            
            let timeAsString = timeFormatter.string(from: dateCreated)
            
            titleLabel.text = dateAsString
            subtitleLabel.text = timeAsString
            
            navigationTitleStackView?.accessibilityLabel = "\(dateAsString) at \(timeAsString)"
        }
    }
}
