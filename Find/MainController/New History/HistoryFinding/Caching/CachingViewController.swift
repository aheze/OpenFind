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
    
    //MARK: Cancel cache
    
    //@IBOutlet weak var cancelGradientView: UIView!
    
    //@IBOutlet weak var cancelBaseView: UIView!
    
   
    
  
    
    
    
    let deviceSize = UIScreen.main.bounds.size
    
    var aspectRatioWidthOverHeight : CGFloat = 0
    var aspectRatioSucceeded : Bool = false
    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
    
    var photos = [EditableHistoryModel]()
    var alreadyCached = [EditableHistoryModel]()
    
    
//    var cachedPhotos = [HistoryModel]()
    
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "taskQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    var statusOk = true ///OK = Running, no cancel
    let swipeView = UIView()

    var isResuming = false
    
    private var gradient: CAGradientLayer!
    private var newGrad:CAGradientLayer!
    
//    var numberCachedLabel = UILabel()
    
    @IBOutlet weak var cancelButton: UIButton!
    var presentingCancelPrompt = false
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("dismiss?")
        statusOk = false
        cancelButton.setTitle("Cancelling...", for: .normal)
        
        
//        if presentingCancelPrompt == false {
//            presentingCancelPrompt = true
//            statusOk = false
//            swipeView.layer.removeAllAnimations()
//            cancelBaseBottomC.constant = 0
//            UIView.animate(withDuration: 0.3, animations: {
//                self.cancelGradientView.alpha = 1
//                self.view.layoutIfNeeded()
//            })
//        } else {
//            presentingCancelPrompt = false
//            cancelBaseBottomC.constant = cancelBaseView.frame.size.height
//            UIView.animate(withDuration: 0.3, animations: {
//                self.cancelGradientView.alpha = 0
//                self.view.layoutIfNeeded()
//            })
//        }
    }
    
    @IBOutlet weak var numberCachedLabel: UILabel!
    
    
    @IBOutlet weak var collectionSuperview: UIView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradient.frame = collectionSuperview.bounds
//        newGrad.frame = cancelGradientView.bounds
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
        
        
        swipeView.frame = CGRect(x: 10, y: 5, width: 10, height: 170)
        swipeView.backgroundColor = UIColor(hexString: "00aeef")
        swipeView.layer.cornerRadius = 5
        newView.addSubview(swipeView)
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse], animations: {

            self.swipeView.frame = CGRect(x: 162, y: 5, width: 10, height: 170)

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

        var frameDiff = (collectionView.frame.size.height - bigRect.size.height) / 2
        collectionView.contentInset.top = frameDiff
        collectionView.contentInset.bottom = frameDiff
        collectionView.contentInsetAdjustmentBehavior = .never
        
        
        view.clipsToBounds = true
//        cancelBaseView.clipsToBounds = true
//        view.bringSubviewToFront(cancelBaseView)
        view.bringSubviewToFront(cancelButton)
        
//        cancelGradientView.alpha = 0
        
//        newGrad = CAGradientLayer()
//        newGrad.frame = cancelGradientView.bounds
//        newGrad.colors = [UIColor.white.cgColor, UIColor(named: "Gray5")!.cgColor]
//        newGrad.locations = [0, 1]
//        gradient.startPoint = CGPoint(x: 0.5, y: 0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 1)
////        cancelGradientView.layer.mask = gradient
//        cancelGradientView.layer.addSublayer(newGrad)
//        cancelGradientView.layer.masksToBounds = true
        
        if isResuming == true {
            cancelButton.setTitle("Resuming...", for: .normal)
        }
        
        
        startFinding()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cacheCellid", for: indexPath) as! CacheCell
        let historyModel = photos[indexPath.item]
//        let historyModel = hisModel[indexPath.item]
        print("CELLFORROW")
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
    
    func finishedCancelling() {
        
        print("Canceling done.")
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(350))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
//            attributes.lifecycleEvents.willDisappear = {
//
//
//
//            }
       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingCancelController") as! CachingCancelController
   
        cacheController.folderURL = folderURL
        cacheController.cachedPhotos = alreadyCached
        cacheController.totalPhotos = photos
        //        cacheController.isResuming = true
                
                
        cacheController.view.layer.cornerRadius = 10
//            print("DAJFSDFSODFIODF: \(folderURL)")
        SwiftEntryKit.display(entry: cacheController, using: attributes)
        
        
    }
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
        dispatchQueue.async {
            var number = 0
            for photo in self.photos {
                if self.statusOk == true {
                    number += 1
                    print("num: \(number)")
                    let indP = IndexPath(item: number - 1, section: 0)
                    DispatchQueue.main.async {
                        print("scrollll")
//                        self.collectionView.performBatchUpdates({
                            self.collectionView.scrollToItem(at: indP, at: .centeredVertically, animated: true)
//                        }, completion: { _ in
                            if self.isResuming == true {
                                print("done?????!!")
                                self.cancelButton.setTitle("Cancel", for: .normal)
                             }
//                        })
                        
                    }
//                    print("photo_____________________________")
                    self.dispatchGroup.enter()
//                    print("photo_____________________________")
//                    print("fold:\(self.folderURL)")
//                    print("FILEPATH: \(photo.filePath)")
                    guard let photoUrl = URL(string: "\(self.folderURL)\(photo.filePath)") else { print("WRONG URL!!!!"); return }
                    
                    
                    guard let photoImage = self.getImageFromDir(photo.filePath) else { print("WRONG IMAGE!!!!"); return }
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
                        self.handleFastDetectedText(request: request, error: error, photo: photo)
                    }
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
                } else {
                    break
                }
            }
        }
        dispatchGroup.notify(queue: dispatchQueue) {
            print("Finished all requests.")
            if self.statusOk == false {
                print("not ok")
                DispatchQueue.main.async {
                    self.finishedCancelling()
                }
            }
        }
        
    }
    func handleFastDetectedText(request: VNRequest?, error: Error?, photo: EditableHistoryModel) {
        guard let results = request?.results, results.count > 0 else {
            //print("no results")
//                busyFastFinding = false
            return
        }

        var contents = [SingleHistoryContent]()
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
//                    let newComponent = EditableHistoryModel()
                for text in observation.topCandidates(1) {
                    print(text.string)
                    
                    
//                        let component = Component()
                    let origX = observation.boundingBox.origin.x
                    let origY = 1 - observation.boundingBox.minY
                    let origWidth = observation.boundingBox.width
                    let origHeight = observation.boundingBox.height
                    
//                    component.text = text.string
//                        let lowerCaseComponentText = text.string.lowercased()
//                        component.text = lowerCaseComponentText
                    let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
                    let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
                    let offHalf = offsetWidth / 2
                    let newW = origWidth * convertedOriginalWidthOfBigImage
                    let newH = origHeight * self.deviceSize.height
                    let newX = origX * convertedOriginalWidthOfBigImage - offHalf
                    let newY = origY * self.deviceSize.height
//                        let individualCharacterWidth = newW / CGFloat(component.text.count)

//                        component.x = newX
//                        component.y = newY
                    let singleContent = SingleHistoryContent()
                    singleContent.text = text.string
                    singleContent.x = Double(newX)
                    singleContent.y = Double(newY)
                    singleContent.width = Double(newW)
                    singleContent.height = Double(newH)
//
                    contents.append(singleContent)
                    

                }
            }

        }

        var newCachedPhoto = EditableHistoryModel()
        newCachedPhoto.dateCreated = photo.dateCreated
        newCachedPhoto.filePath = photo.filePath
        newCachedPhoto.isDeepSearched = true
        newCachedPhoto.isHearted = photo.isHearted
        newCachedPhoto.contents = contents
        
        alreadyCached.append(newCachedPhoto)
        
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
