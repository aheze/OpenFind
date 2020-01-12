




import UIKit


extension ViewController {
    
    func saveImage(url : URL, imageName: String, image: UIImage) {
        let fileURL = url.appendingPathComponent("\(imageName)")
        print(fileURL)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        do {

            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
       
    }

    @IBAction func buttonTouchDown(_ sender: NewShutterButton) {
        print("down")
        
        sender.zoomOutWithEasing(duration: 0.07, easingOffset: 0.1)
    }
    
    @IBAction func buttonTouchUp(_ sender: NewShutterButton) {
        print("up")
        sender.zoomInWithEasing(duration: 0.06)
        saveToFile()
    }
    @IBAction func buttonTouchUpOutside(_ sender: NewShutterButton) {
        sender.zoomInWithEasing(duration: 0.06)
        print("up outside")
    }
    
    func animateShutterOverlay() {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        let newView = UIView()
        view.insertSubview(newView, aboveSubview: sceneView)
        newView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        newView.alpha = 0
        newView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.07, animations: {
            newView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.12, delay: 0.06, animations: {
                newView.alpha = 0
            }) { _ in
                newView.removeFromSuperview()
            }
            
        })
        
    }
    func saveToFile() {
        if let capturedImage = sceneView.session.currentFrame?.capturedImage {
            var ciImage = CIImage(cvPixelBuffer: capturedImage)
            let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
            ciImage = ciImage.transformed(by: transform)
            let size = ciImage.extent.size
            let screenSize: CGRect = UIScreen.main.bounds
            let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
                return
            }
            let uiImage = UIImage(cgImage: cgImage)
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMddyy"
            let dateAsString = formatter.string(from: date)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HHmmss.SSSS"
            let timeAsString = timeFormatter.string(from: date)
            print("date=\(dateAsString).time=\(timeAsString)")
            saveImage(url: globalUrl, imageName: "=\(dateAsString)=\(timeAsString)", image: uiImage)
            animateShutterOverlay()
//            UIView.animate(withDuration: 0.3, animations: {
//    //                    self.photoButton.alpha = 0
//                self.menuButton.alpha = 0
//
//            }, completion: { _ in
//                self.menuButton.isHidden = true
//    //                    self.photoButton.isHidden = true
//
//            })
        }
    }
//    @IBAction func didTapButton(_ sender: ShutterButton) {
//        
//        print(sender.buttonState)
//        switch sender.buttonState {
//        case .normal:
//            //changeHUDSize(to: CGSize(width: 55, height: 120))
//            sender.buttonState = .recording
//            
//            sceneView.session.pause()
//            
//            if let capturedImage = sceneView.session.currentFrame?.capturedImage {
//                
//                
//                var ciImage = CIImage(cvPixelBuffer: capturedImage)
//                let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
//                ciImage = ciImage.transformed(by: transform)
//                let size = ciImage.extent.size
//                
//                let screenSize: CGRect = UIScreen.main.bounds
//                let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
//                let context = CIContext(options: nil)
//                guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
//                    return
//                }
//                let uiImage = UIImage(cgImage: cgImage)
//                //                self.freezeImageArray.append(uiImage)
//                let date = Date()
//                
//                let formatter = DateFormatter()
//                formatter.dateFormat = "MMddyy"
//                let dateAsString = formatter.string(from: date)
//                
//                
//                let timeFormatter = DateFormatter()
//                timeFormatter.dateFormat = "HHmmss.SSSS"
//                let timeAsString = timeFormatter.string(from: date)
//                print("date=\(dateAsString).time=\(timeAsString)")
//                saveImage(url: globalUrl, imageName: "=\(dateAsString)=\(timeAsString)", image: uiImage)
//                UIView.animate(withDuration: 0.3, animations: {
////                    self.photoButton.alpha = 0
//                    self.menuButton.alpha = 0
//                    
//                }, completion: { _ in
//                    self.menuButton.isHidden = true
////                    self.photoButton.isHidden = true
//                    
//                    
//                })
//            }
//
//            
//            
//        case .recording:
//            sender.buttonState = .normal
////            changeHUDSize(to: CGSize(width: 55, height: 55))
//            
//            self.menuButton.isHidden = false
////            self.photoButton.isHidden = false
//            UIView.animate(withDuration: 0.3, animations: {
//                self.menuButton.alpha = 1
////                 self.photoButton.alpha = 1
//            }, completion: nil)
//            if let config = sceneView.session.configuration {
//            sceneView.session.run(config)
//            }
//        }
//    }

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
