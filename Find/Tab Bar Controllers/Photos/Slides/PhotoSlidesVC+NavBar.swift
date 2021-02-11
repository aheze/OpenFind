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
        
        navigationItem.rightBarButtonItems = [findButton]
    }
    func makeTitleView() {
        let baseView = UIView()
        
        let contentView = UIView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        
        baseView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        contentView.backgroundColor = .clear
        
        baseView.backgroundColor = .gray
        
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        
        titleLabel.text = "January 14"
        subtitleLabel.text = "8:29 PM"
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(subtitleLabel.snp.top)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        navigationItem.titleView = baseView
        
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
        }
    }
}
