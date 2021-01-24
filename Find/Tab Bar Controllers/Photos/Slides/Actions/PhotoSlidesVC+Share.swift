//
//  PhotoSlidesVC+Share.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import LinkPresentation

extension PhotoSlidesViewController {
    func sharePhoto() {
        let currentAsset = resultPhotos[currentIndex].findPhoto.asset
        
        DispatchQueue.global(qos: .userInitiated).async {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            manager.requestImage(for: currentAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { (result, info) in
                if let photo = result {
                    
                    self.imageToShare = photo
                    
                    DispatchQueue.main.async {
                        let activityViewController = UIActivityViewController(activityItems: [photo, self], applicationActivities: nil)
                        
                        
                        if let popoverController = activityViewController.popoverPresentationController {
                            popoverController.sourceRect = CGRect(x: 10, y: self.view.bounds.height - 50, width: 20, height: 20)
                            popoverController.sourceView = self.view
                        }
                        
                        self.present(activityViewController, animated: true)
                        
                    }
                }
            })
        }
    }
}


extension PhotoSlidesViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let image = imageToShare else { return nil }
        let pngImage = image.pngData()
        let imageSize = pngImage?.count ?? 0
        
        let fileSize = ByteCountFormatter.string(fromByteCount: Int64(imageSize), countStyle: .file)
        
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.title = "Photo"
        metadata.originalURL = URL(fileURLWithPath: "PNG Image • \(fileSize)")
        metadata.imageProvider = imageProvider
        return metadata
    }
}
