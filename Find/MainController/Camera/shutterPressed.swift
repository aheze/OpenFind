




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

    @IBAction func didTapButton(_ sender: ShutterButton) {
        
        switch sender.buttonState {
        case .normal:
            sender.buttonState = .recording
            
            sceneView.session.pause()
            
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
                //                self.freezeImageArray.append(uiImage)
                let date = Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMddyy"
                let dateAsString = formatter.string(from: date)
                
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HHmmss.SSSS"
                let timeAsString = timeFormatter.string(from: date)
                print("date=\(dateAsString).time=\(timeAsString)")
                saveImage(url: globalUrl, imageName: "=\(dateAsString)=\(timeAsString)", image: uiImage)
                UIView.animate(withDuration: 0.3, animations: {
                    self.photoButton.alpha = 0
                    self.menuButton.alpha = 0
                    
                }, completion: { _ in
                    self.menuButton.isHidden = true
                    self.photoButton.isHidden = true
                    
                    
                })
            }

            
            
        case .recording:
            sender.buttonState = .normal
            
            
            self.menuButton.isHidden = false
            self.photoButton.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.menuButton.alpha = 1
                self.photoButton.alpha = 1
            }, completion: nil)
            if let config = sceneView.session.configuration {
            sceneView.session.run(config)
            }
        }
    }

}
