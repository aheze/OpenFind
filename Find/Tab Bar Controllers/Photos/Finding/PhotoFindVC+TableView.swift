//
//  PhotoFindVC+TableView.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImagePhotosPlugin

extension PhotoFindViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        cell.baseView.layer.cornerRadius = 6
        cell.baseView.clipsToBounds = true
        
        let findModel = resultPhotos[indexPath.row]
        
        var numberText = ""
        if findModel.numberOfMatches == 1 {
            let oneMatch = NSLocalizedString("oneMatch", comment: "Multifile def=1 match")
            numberText = oneMatch
        } else {
            
            let xSpaceMatches = NSLocalizedString("%d SpaceMatches", comment: "HistoryFindController def=x matches")
            let string = String.localizedStringWithFormat(xSpaceMatches, findModel.numberOfMatches)
            numberText = string
        }
            
        
        if let creationDate = findModel.findPhoto.asset.creationDate?.convertDateToReadableString() {
            cell.titleLabel.text = "\(creationDate)"
        }

        cell.textView.text = findModel.descriptionText
        
        
        if let url = NSURL.sd_URL(with: findModel.findPhoto.asset) {

            cell.photoImageView.sd_imageTransition = .fade
            cell.photoImageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue])
            
        }

        cell.textView.layoutManager.ensureLayout(for: cell.textView.textContainer)
        
        var rects = [CGRect]()
        cell.drawingView.subviews.forEach({ $0.removeFromSuperview() })
        for range in findModel.descriptionMatchRanges {
            guard let first = range.descriptionRange.first else { continue }
            guard let last = range.descriptionRange.last else { continue }
            guard let start = cell.textView.position(from: cell.textView.beginningOfDocument, offset: first) else { continue }
            // text position of the end of the range
            guard let end = cell.textView.position(from: cell.textView.beginningOfDocument, offset: last) else { continue }
            
            if let textRange = cell.textView.textRange(from: start, to: end) {
                // here it is!
                let rect = cell.textView.firstRect(for: textRange)
                rects.append(rect)
                
                let newHighlight = addHighlight(text: range.text, rect: rect)
                cell.drawingView.addSubview(newHighlight)
            }
        }
        
        return cell
    }
}
