//
//  PhotoSlidesVC+NavBar.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotoSlidesViewController {
    func setNavigationBar() {
        makeTitleView()
        
        navigationItem.largeTitleDisplayMode = .never
        
        findButton = UIBarButtonItem(title: NSLocalizedString("universal-find", comment: ""), style: .plain, target: self, action: #selector(findPressed(sender:)))
        findButton.tintColor = UIColor(named: "PhotosText")
        findButton.accessibilityHint = "Find from this photo. Displays a search bar."
        
        navigationItem.rightBarButtonItems = [findButton]
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
    func makeTitleView() {
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
        
        self.navigationTitleStackView = stackView
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        
        updateNavigationTitle(to: resultPhotos[currentIndex].findPhoto)
    }
    
    func updateNavigationTitle(to findPhoto: FindPhoto) {
        if let dateCreated = findPhoto.asset.creationDate {
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

extension UINavigationItem {
    func setTitle(title: String, subtitle: String) {
        
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 17)
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
}
