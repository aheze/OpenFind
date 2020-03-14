//
//  CachingViewController.swift
//  Find
//
//  Created by Zheng on 3/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftEntryKit
import Vision

protocol ReturnCachedPhotos: class {
    
    func giveCachedPhotos(photos: HistoryModel)
}
class CachingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let deviceSize = UIScreen.main.bounds.size
    
    var aspectRatioWidthOverHeight : CGFloat = 0
    var aspectRatioSucceeded : Bool = false
    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
    
    var photos = [EditableHistoryModel]()
    var cachePhotos = [HistoryModel]()
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "taskQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    private var gradient: CAGradientLayer!
    
//    var numberCachedLabel = UILabel()
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("dismiss?")
    }
    
    @IBOutlet weak var numberCachedLabel: UILabel!
    
    
    @IBOutlet weak var collectionSuperview: UIView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradient.frame = collectionSuperview.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("load")
        print(photos.count)
        cancelButton.layer.cornerRadius = 6
//        machineView.layer.cornerRadius = 4
        
        let bigRect = CGRect(x: 0, y: 0, width: 180, height: 180)
        
        let pathBigRect = UIBezierPath(roundedRect: bigRect, cornerRadius: 4)
        let smallRect = CGRect(x: 10, y: 10, width: 160, height: 160)
        
        let pathSmallRect = UIBezierPath(roundedRect: smallRect, cornerRadius: 2)
//
        pathBigRect.append(pathSmallRect)
        pathBigRect.usesEvenOddFillRule = true
//
        let fillLayer = CAShapeLayer()
        fillLayer.path = pathBigRect.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor(named: "Gray4")?.cgColor
        //fillLayer.opacity = 0.4
        
        let newView = UIView()
        newView.layer.addSublayer(fillLayer)
        view.addSubview(newView)
        newView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 180, height: 180))
            make.center.equalToSuperview()
        }
        
        let tintView = UIView()
        tintView.frame = CGRect(x: 10, y: 10, width: 160, height: 160)
        tintView.layer.cornerRadius = 2
        tintView.backgroundColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 0.12)
        newView.addSubview(tintView)
        
        let swipeView = UIView()
        swipeView.frame = CGRect(x: 10, y: 5, width: 10, height: 170)
        swipeView.backgroundColor = UIColor(hexString: "00aeef")
        swipeView.layer.cornerRadius = 5
        newView.addSubview(swipeView)
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse], animations: {

            swipeView.frame = CGRect(x: 162, y: 5, width: 10, height: 170)

        }, completion: nil)
        
        
//        let gradient = CAGradientLayer()
        gradient = CAGradientLayer()
        gradient.frame = collectionSuperview.bounds
        
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.16, 0.84, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        collectionSuperview.layer.mask = gradient
        collectionSuperview.layer.masksToBounds = true

        collectionView.contentInset.top = collectionSuperview.frame.size.height
        collectionView.contentInset.bottom = collectionSuperview.frame.size.height
        
        
        startFinding()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cacheCellid", for: indexPath) as! CacheCell
        let historyModel = photos[indexPath.item]
//        let historyModel = hisModel[indexPath.item]
        
        var filePath = historyModel.filePath
        let urlPath = "\(folderURL)\(filePath)"
//        print(urlPath)
        
        let finalUrl = URL(string: urlPath)
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.imageView.sd_imageTransition = .fade
        cell.imageView.sd_setImage(with: finalUrl)
        
        return cell
    }
    
    
}
extension CachingViewController {
    
    func getImageFromDir(_ imageName: String) -> UIImage? {

        if let fileURL = URL(string: "\(folderURL)\(imageName)") {
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Not able to load image")
            }
        }
        return nil
    }
    func startFinding() {
        print("start")
//        dispatchQueue.async {
//
//            for c in self.categories {
//
//                if let id = c.categoryId {
//
//                    dispatchGroup.enter()
//
//                    self.downloadProductsByCategory(categoryId: id) { success, data in
//
//                        if success, let products = data {
//
//                            self.products.append(products)
//                        }
//
//                        dispatchSemaphore.signal()
//                        dispatchGroup.leave()
//                    }
//
//                    dispatchSemaphore.wait()
//                }
//            }
//        }
        dispatchQueue.async {
            for photo in self.photos {
                print("photo")
                self.dispatchGroup.enter()

                print("fold:\(self.folderURL)")
                print("FILEPATH: \(photo.filePath)")
                guard let photoUrl = URL(string: "\(self.folderURL)\(photo.filePath)") else { print("WRONG URL!!!!"); return }
    //            guard let photoImage = UIImage(contentsOfFile: "\(folderURL)\(photo.filePath)") else { print("WRONG IMAGE!!!!"); return }
                guard let photoImage = self.getImageFromDir(photo.filePath) else { print("WRONG IMAGE!!!!"); return }
                 
                
                
    //            Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"]).responseJSON { response in
    //                print("Finished request \(i)")
                
                
    //            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let width = photoImage.size.width
                let height = photoImage.size.height
                self.sizeOfPixelBufferFast = CGSize(width: width, height: height)
                //print(width)
                //print(height)
                self.aspectRatioWidthOverHeight = height / width ///opposite
                if self.aspectRatioWidthOverHeight != CGFloat(0) {
                    self.aspectRatioSucceeded = true
                }
                //let request = fastTextDetectionRequest
                let request = VNRecognizeTextRequest { request, error in
              
                    self.handleFastDetectedText(request: request, error: error)
                }
                
    //            var customFindArray = [String]()
    //            for list in self.selectedLists {
    //                for cont in list.contents {
    //                    customFindArray.append(cont)
    //                    customFindArray.append(cont.lowercased())
    //                    customFindArray.append(cont.uppercased())
    //                    customFindArray.append(cont.capitalizingFirstLetter())
    //
    //                }
    //            }
                
    //            request.customWords = [self.finalTextToFind, self.finalTextToFind.lowercased(), self.finalTextToFind.uppercased(), self.finalTextToFind.capitalizingFirstLetter()] + customFindArray
    //            request.progressHandler = { (request, value, error) in
    //                //print(value)
    //                self.updateStatusViewProgress(to: CGFloat(value))
    //            }
                
                request.recognitionLevel = .accurate
                request.recognitionLanguages = ["en_GB"]
                let imageRequestHandler = VNImageRequestHandler(url: photoUrl, orientation: .up)
                //DispatchQueue.global().async {
                do {
                    try imageRequestHandler.perform([request])
                } catch let error {
    //                self.busyFastFinding = false
                    print("Error: \(error)")
                }
                
                self.dispatchSemaphore.wait()
    //                dispatchGroup.leave()
    //            }
            }

        }
        dispatchGroup.notify(queue: dispatchQueue) {
            print("Finished all requests.")
        }
        
    }
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
            guard let results = request?.results, results.count > 0 else {
                //print("no results")
//                busyFastFinding = false
                return
            }

            for result in results {
                if let observation = result as? VNRecognizedTextObservation {
                    for text in observation.topCandidates(1) {
                        print(text.string)
                        let component = Component()
                        component.x = observation.boundingBox.origin.x
                        component.y = 1 - observation.boundingBox.minY
                        component.height = observation.boundingBox.height
                        component.width = observation.boundingBox.width
    //                    component.text = text.string
                        let lowerCaseComponentText = text.string.lowercased()
                        component.text = lowerCaseComponentText
                        let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
                        let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
                        let offHalf = offsetWidth / 2
                        let newW = component.width * convertedOriginalWidthOfBigImage
                        let newH = component.height * self.deviceSize.height
                        let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
                        let newY = component.y * self.deviceSize.height
                        let individualCharacterWidth = newW / CGFloat(component.text.count)

                        component.x = newX
                        component.y = newY
//


                    }
                }

            }

            dispatchSemaphore.signal()
            dispatchGroup.leave()
//            busyFastFinding = false
//            animateFoundFastChange()
//            numberOfFastMatches = 0
        }
}
extension CachingViewController : UICollectionViewDelegateFlowLayout {
  //1
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 3
    return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
