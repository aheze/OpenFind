//
//  ShutterPressed.swift
//  Find
//
//  Created by Andrew on 1/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

extension ViewController {
    
    func saveImage(url: URL, imageName: String, image: UIImage, dateCreated: Date) {

        let fileURL = url.appendingPathComponent("\(imageName)")
        print(fileURL)
        print("SAVE!!!!!!")
        DispatchQueue.global().async {
            guard let data = image.jpegData(compressionQuality: 1) else { return }
            do {
                try data.write(to: fileURL)
            } catch let error {
                print("error saving file with error", error)
            }
        }
        let newHist = HistoryModel()
        newHist.filePath = "\(imageName)"
        newHist.dateCreated = dateCreated
        do {
            try realm.write {
                realm.add(newHist)
            }
        } catch {
            print("Error saving category \(error)")
        }
       
    }

    @IBAction func buttonTouchDown(_ sender: NewShutterButton) {
        sender.zoomOutWithEasing(duration: 0.07, easingOffset: 0.1)
    }
    
    @IBAction func buttonTouchUp(_ sender: NewShutterButton) {
        
        AppStoreReviewManager.requestReviewIfAppropriate()
        sender.zoomInWithEasing(duration: 0.06)
        animateShutterOverlay()
        saveToFile()
    }
    @IBAction func buttonTouchUpOutside(_ sender: NewShutterButton) {
        sender.zoomInWithEasing(duration: 0.06)
    }
    
    func animateShutterOverlay() {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        let newView = UIView()
        view.insertSubview(newView, aboveSubview: cameraView)
        newView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        newView.alpha = 0
        newView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.09, animations: {
            newView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.11, delay: 0.01, animations: {
                newView.alpha = 0
            }) { _ in
                newView.removeFromSuperview()
            }
        })
    }
    func saveToFile() {
        capturePhoto { image in
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMddyy"
            let dateAsString = formatter.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HHmmss-SSSS"
            let timeAsString = timeFormatter.string(from: date)
            print("Date=\(dateAsString), time=\(timeAsString)")
            self.saveImage(url: self.globalUrl, imageName: "=\(dateAsString)=\(timeAsString)", image: image, dateCreated: date)
        }
    }
    
    func preloadAllImages() {

        let imageArray =  [
        "=062720=154754-1000",
        "=062720=154755-1000",
        "=062720=154756-1000",
        "=062720=154757-1000",
        "=062720=154758-1000",
        "=062720=154759-1000",
        "=062720=154700-1000",
        "=062720=154701-1000",
            
        "=062620=154702-1000",
        "=062620=154703-1000",
        "=062620=154704-1000",
        "=062620=154705-1000",
        "=062620=154706-1000",
        "=062620=154707-1000",
        "=062620=154708-1000",
        "=062620=154709-1000",
        "=062620=154710-1000",
        "=062620=154711-1000"
        ]
        
        print("imageArray count: \(imageArray.count)")
        preloadImages(imageNames: imageArray)
    }
    
    func preloadImages(imageNames: [String]) {
        
        for (index, imageName) in imageNames.enumerated() {
            print("index: \(index)")
            
            let splits = imageName.components(separatedBy: "=")
            print("splits: \(splits)")
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MMddyy"
//            guard let dateFromString = dateFormatter.date(from: splits[1]) else { print("Wrong date 1"); return}
//
//
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateFormat = "HHmmss'-'SSSS"
//            guard let timeFromString = timeFormatter.date(from: splits[2]) else { print("Wrong date 2"); return}
//
            let finalDateFormatter = DateFormatter()
            finalDateFormatter.dateFormat = "'='MMddyy'='HHmmss'-'SSSS"
            guard let finalDate = finalDateFormatter.date(from: imageName) else { print("Wrong date 3"); continue}
            
//            let imageName = "=\(dateFromString)=\(timeFromString)"
            
            print("imagename: \(imageName)")
            
            if let image = UIImage(named: imageName) {
                saveImage(url: self.globalUrl, imageName: imageName, image: image, dateCreated: finalDate)
            }
            
//            preloadSave(date: finalDate, dateNameString: imageName, image: UIImage(named: imageName)!)
            
           
        }
    }
}
extension UIView {

    /**
     Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.

     - parameter duration: animation duration
     */
    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }

    /**
     Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.

     - parameter duration: animation duration
     */
    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
        }
    }

    /**
     Zoom in any view with specified offset magnification.

     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        })
    }

    /**
     Zoom out any view with specified offset magnification.

     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 - easingOffset
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        })
    }
}
