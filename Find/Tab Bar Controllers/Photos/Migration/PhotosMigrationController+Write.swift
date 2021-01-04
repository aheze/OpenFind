//
//  PhotosMigrationController+Write.swift
//  Find
//
//  Created by Zheng on 1/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SPAlert
import Photos

extension PhotosMigrationController {
    func writeToPhotos(photoURLs: [URL]) {
        self.isModalInPresentation = true
        cancelButton.isEnabled = false
        confirmButton.isEnabled = false
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, animations: {
                self.blurView.effect = UIBlurEffect(style: .regular)
                self.segmentIndicator.alpha = 1
                self.movingLabel.alpha = 1
                self.progressLabel.alpha = 1
            })
        }
        
        dispatchQueue.async {
            
            var dataArray = [Data]()
            for url in photoURLs {
                do {
                    let data = try Data(contentsOf: url)
                    dataArray.append(data)
                } catch {
                    print("error making data: \(error)")
                }
            }
            
            for data in dataArray {
                PHPhotoLibrary.shared().performChanges({
                    
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    //                        creationRequest.addResource(with: .photo, fileURL: url, options: options)
                    creationRequest.addResource(with: .photo, data: data, options: nil)
                    print("added")
                    
                    
                    
                    
                }) { (success, error) in
                    if !success {
                        print("Error saving asset to library:\(String(describing: error?.localizedDescription))")
                    }
                    print("saved")
                    
                    self.dispatchSemaphore.signal()
//                    self.dispatchGroup.leave()
                    
                    DispatchQueue.main.async {
                        self.savedAnotherImage()
                    }
                }
                
                self.dispatchSemaphore.wait()
            }
            //                self.dispatchGroup.enter()
            //                do {
//                    try PHPhotoLibrary.shared().performChangesAndWait {
//                        print("performing, \(photoURL)")
//
//                        if let image = UIImage(contentsOfFile: photoURL.path) {
//
//
//                            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                            let localID = request.placeholderForCreatedAsset?.localIdentifier
//                            print("Done, id: \(localID)")
//                        }
////                        self.dispatchGroup.leave()
//
//                        DispatchQueue.main.async {
//                            self.savedAnotherImage()
//                        }
//                    }
//                } catch {
//                    print("err;r \(error)")
//                }
//            }
        }
         
        

//        dispatchGroup.notify(queue: .main) {
//            print("Finished all requests.")
//            let alertView = SPAlertView(title: "Finished", message: "Your photos have been moved to the Photos app.", preset: SPAlertPreset.done)
//            alertView.duration = 2.6
//            alertView.present()
//            self.dismiss(animated: true, completion: nil)
//        }
       
    }
    
    func savedAnotherImage() {
        numberCompleted += 1
        let percentComplete = CGFloat(numberCompleted) / CGFloat(photoURLs.count)
        let percentCompleteOf100 = percentComplete * 100
        
        progressLabel.fadeTransition(0.1)
        progressLabel.text = "\(Int(percentCompleteOf100))%"
        
        segmentIndicator.updateProgress(percent: Degrees(percentCompleteOf100))
    }
    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
//
//        dispatchGroup.leave()
//        numberCompleted += 1
//        let percentComplete = CGFloat(numberCompleted) / CGFloat(photoURLs.count)
//        let percentCompleteOf100 = percentComplete * 100
//
//        progressLabel.fadeTransition(0.1)
//        progressLabel.text = "\(Int(percentCompleteOf100))%"
//
//        segmentIndicator.updateProgress(percent: Degrees(percentCompleteOf100))
//        if let error = error {
//            print("Error saving: \(error)")
//        }
//    }
}
