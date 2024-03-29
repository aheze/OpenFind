//
//  PhotoFindVC+TableView.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SDWebImage
import SDWebImagePhotosPlugin
import UIKit

extension PhotoFindViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        
        cell.baseView.layer.cornerRadius = 8
        cell.baseView.clipsToBounds = true
        
        cell.shadowView.layer.masksToBounds = false
        cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.shadowView.layer.shadowColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        cell.shadowView.layer.shadowOpacity = 0.5
        cell.shadowView.layer.shadowRadius = 4
        
        if resultPhotos.indices.contains(indexPath.row) {
            let findModel = resultPhotos[indexPath.row]
            
            if let model = findModel.findPhoto.editableModel {
                if model.isDeepSearched {
                    cell.cacheImageView.image = UIImage(named: "CacheActive-Light")
                } else {
                    cell.cacheImageView.image = nil
                }
                if model.isHearted {
                    cell.starImageView.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
                } else {
                    cell.starImageView.image = nil
                }
                if model.isDeepSearched || model.isHearted {
                    cell.shadowImageView.image = UIImage(named: "DownShadow")
                } else {
                    cell.shadowImageView.image = nil
                }
            } else {
                cell.cacheImageView.image = nil
                cell.starImageView.image = nil
                cell.shadowImageView.image = nil
            }
            
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
            
            cell.numberOfMatchesView.layer.cornerRadius = cell.numberOfMatchesView.bounds.height / 2
            cell.numberOfMatchesLabel.text = numberText
            
            cell.textView.text = findModel.descriptionText
            
            let url = NSURL.sd_URL(with: findModel.findPhoto.asset)
            
            cell.photoImageView.sd_imageTransition = .fade
            cell.photoImageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue])
            
            cell.textView.layoutManager.ensureLayout(for: cell.textView.textContainer)
            
            var rects = [CGRect]()
            cell.drawingView.subviews.forEach { $0.removeFromSuperview() }
            
            let attributedVoiceOverDescription = NSMutableAttributedString(string: cell.textView.text)
            
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
                    
                    if
                        let colors = matchToColors[range.text],
                        let firstColor = colors.first
                    {
                        attributedVoiceOverDescription.addAttributes(
                            [.accessibilitySpeechPitch: firstColor.hexString.getDescription().1],
                            range:
                            NSRange(
                                location:
                                range.descriptionRange.first ?? 0,
                                length: (range.descriptionRange.last ?? 0) - (range.descriptionRange.first ?? 0)
                            )
                        )
                    }
                }
            }
            
            cell.textView.isAccessibilityElement = true
            cell.textView.accessibilityTraits = .staticText
            
            let uninterruptedText = findModel.descriptionText.replacingOccurrences(of: "...", with: " ")
            
            let excerptTitle = AccessibilityText(text: "Excerpt:", isRaised: true)
            let excerptString = AccessibilityText(text: uninterruptedText, isRaised: false)
            let pitchesTitle = AccessibilityText(text: "Emphasizing pitches:", isRaised: true)
            
            let attributedString = UIAccessibility.makeAttributedText([excerptTitle, excerptString, pitchesTitle])
            cell.textView.accessibilityAttributedLabel = attributedString + attributedVoiceOverDescription
            cell.textView.accessibilityValue = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentFromIndexPath(indexPath: indexPath)
    }
}
