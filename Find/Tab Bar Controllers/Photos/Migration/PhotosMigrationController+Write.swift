//
//  PhotosMigrationController+Write.swift
//  Find
//
//  Created by Zheng on 1/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SPAlert

extension PhotosMigrationController {
    func writeToPhotos(photoURLs: [URL]) {
        self.isModalInPresentation = true
        cancelButton.isEnabled = false
        confirmButton.isEnabled = false
        
        UIView.animate(withDuration: 0.8, animations: {
            self.blurView.effect = UIBlurEffect(style: .regular)
            self.segmentIndicator.alpha = 1
            self.movingLabel.alpha = 1
            self.progressLabel.alpha = 1
        })
        
        for photoURL in photoURLs {
            dispatchGroup.enter()
            if let image = UIImage(contentsOfFile: photoURL.path) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Finished all requests.")
            let alertView = SPAlertView(title: "Finished", message: "Your photos have been moved to the Photos app.", preset: SPAlertPreset.done)
            alertView.duration = 2.6
            alertView.present()
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        dispatchGroup.leave()
        numberCompleted += 1
        let percentComplete = CGFloat(numberCompleted) / CGFloat(photoURLs.count)
        let percentCompleteOf100 = percentComplete * 100
        
        progressLabel.fadeTransition(0.1)
        progressLabel.text = "\(Int(percentCompleteOf100))%"
        
        segmentIndicator.updateProgress(percent: Degrees(percentCompleteOf100))
        if let error = error {
            print("Error saving: \(error)")
        }
    }
}
