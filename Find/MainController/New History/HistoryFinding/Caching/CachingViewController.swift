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
import SPAlert
import RealmSwift

protocol ReturnCachedPhotos: class {
    
    func giveCachedPhotos(photos: HistoryModel)
}
class CachingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: Cancel cache
    
    //@IBOutlet weak var cancelGradientView: UIView!
    
    //@IBOutlet weak var cancelBaseView: UIView!
    
   
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var count = 0
    
    let rimView = UIView()
    let tintView = UIView()
    let swipeView = UIView()
    
    
    @IBAction func keepButtonPressed(_ sender: Any) {
    }
    @IBAction func discardButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    @IBAction func backButtonPressed(_ sender: Any) {
//        startFinding()
        animateChange(toCancel: false)
        
    }
    
    
    
    @IBOutlet weak var baseView: UIView!
    
    
    let deviceSize = UIScreen.main.bounds.size
    
    var aspectRatioWidthOverHeight : CGFloat = 0
    var aspectRatioSucceeded : Bool = false
    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
    
    var photos = [EditableHistoryModel]()
//    var alreadyCached = [EditableHistoryModel]()
    
    
    var cachedPhotos = [HistoryModel]()
    
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "taskQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    var statusOk = true ///OK = Running, no cancel
    

    var isResuming = false
    
    private var gradient: CAGradientLayer!
    private var newGrad:CAGradientLayer!
    
//    var numberCachedLabel = UILabel()
    
    @IBOutlet weak var cancelButton: UIButton!
    var presentingCancelPrompt = false
    
    weak var finishedCache: ReturnCachedPhotos?
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("dismiss?")
        statusOk = false
        cancelButton.setTitle("Cancelling...", for: .normal)
        
        var newLabel = ""
        if count == 1 {
            newLabel = """
            1 photo has already been cached.
            Would you like to keep its cache?
            """
        } else {
            newLabel = """
            \(count) photos have already been cached.
            Would you like to keep their caches?
            """
        }
        cancelLabel.text = newLabel
        
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
        setUpViews()
        cancelView.isHidden = true
        backButton.isHidden = true
        cancelView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        startFinding()
    }
    
    func animateChange(toCancel: Bool) {
        if toCancel == true {
            self.cancelView.isHidden = false
            self.backButton.isHidden = false
//            self.statusOk = false
            UIView.animate(withDuration: 0.4, animations: {
                self.baseView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.cancelView.transform = CGAffineTransform.identity
                
                self.baseView.alpha = 0
                self.cancelView.alpha = 1
                self.backButton.alpha = 1
                
                self.rimView.alpha = 0
                self.tintView.alpha = 0
                self.swipeView.alpha = 0
                
            }, completion: { _ in
                self.baseView.isHidden = true
                
                self.rimView.isHidden = true
                self.tintView.isHidden = true
                self.swipeView.isHidden = true
            })
            
        } else {
            self.baseView.isHidden = false
            self.rimView.isHidden = false
            self.tintView.isHidden = false
            self.swipeView.isHidden = false
            
            self.statusOk = true
            
            cancelButton.setTitle("Cancel", for: .normal)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.baseView.transform = CGAffineTransform.identity
                self.cancelView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                
                self.baseView.alpha = 1
                self.cancelView.alpha = 0
                self.backButton.alpha = 0
                
                self.rimView.alpha = 1
                self.tintView.alpha = 1
                self.swipeView.alpha = 1
                
                
            }, completion: { _ in
                print("completed")
                self.cancelView.isHidden = true
                self.backButton.isHidden = true
                self.startFinding()
            })
            
        }
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
    
    func finishedFind() {
        DispatchQueue.main.async {
            self.cancelButton.isEnabled = false
            let alertView = SPAlertView(title: "Caching done!", message: nil, preset: SPAlertPreset.done)
            alertView.duration = 2.2
            alertView.present()
            
            for photo in self.photos {
                let histModel = HistoryModel()
                histModel.filePath = photo.filePath
                histModel.dateCreated = photo.dateCreated
                histModel.isDeepSearched = photo.isDeepSearched
                histModel.isHearted = photo.isHearted
                for cont in photo.contents {
                    histModel.contents.append(cont)
                }
                self.cachedPhotos.append(histModel)
            }
//            self.finishedCache?.giveCachedPhotos(photos: <#T##HistoryModel#>)
            SwiftEntryKit.dismiss()
        }
        
    }
    func finishedCancelling() {
        
        print("Canceling done.")
        animateChange(toCancel: true)
//        var attributes = EKAttributes.centerFloat
//        attributes.displayDuration = .infinity
//        attributes.entryInteraction = .absorbTouches
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
//        attributes.entryBackground = .color(color: .white)
//        attributes.screenInteraction = .absorbTouches
//        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(350))
//        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
////            attributes.lifecycleEvents.willDisappear = {
////
//
//
//            }
       
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingCancelController") as! CachingCancelController
//
//
//        //        cacheController.isResuming = true
//
//
//
//
//        addChild(cacheController)
//
////        addChildViewController(childVC)
//        //Or, you could add auto layout constraint instead of relying on AutoResizing contraints
//        cacheController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        cacheController.view.frame = containerView.bounds
//
//        containerView.addSubview(cacheController.view)
//        cacheController.didMove(toParent: self)
//
//
        
        
        //Some property on ChildVC that needs to be set
//        childVC.dataSource = self
        
//            print("DAJFSDFSODFIODF: \(folderURL)")
//        SwiftEntryKit.display(entry: cacheController, using: attributes)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCancel" {
            
            if let cacheController = segue.destination as? CachingCancelController {
              //Some property on ChildVC that needs to be set
              cacheController.folderURL = folderURL
              //        cacheController.cachedPhotos = alreadyCached
              cacheController.totalPhotos = photos
              cacheController.view.layer.cornerRadius = 10
            }
        }
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
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.swipeView.frame = CGRect(x: 162, y: 5, width: 10, height: 170)
        }, completion: nil)
        
        dispatchQueue.async {
            var number = 0
            for photo in self.photos {
                if self.statusOk == true {
                    number += 1
                    print("num: \(number)")
                    if !photo.isDeepSearched {
                        
                        let indP = IndexPath(item: number - 1, section: 0)
                        DispatchQueue.main.async {
                            print("scrollll")
    //                        self.collectionView.performBatchUpdates({
                                self.collectionView.scrollToItem(at: indP, at: .centeredVertically, animated: true)
    //                        }, completion: { _ in
//                                if self.isResuming == true {
//                                    print("done?????!!")
//                                    self.cancelButton.setTitle("Cancel", for: .normal)
//                                 }
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
                        print("ALREADY!!")
//                        self.dispatchSemaphore.signal()
//                        self.dispatchGroup.leave()
                        continue
                    }
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
            } else {
                self.finishedFind()
            }
        }
        
    }
    func handleFastDetectedText(request: VNRequest?, error: Error?, photo: EditableHistoryModel) {
        
        count += 1
        DispatchQueue.main.async {
            self.numberCachedLabel.text = "\(self.count)/\(self.photos.count) photos cached"
        }
        guard let results = request?.results, results.count > 0 else {
            print("no results")
//                busyFastFinding = false
            
            let newCachedPhoto = EditableHistoryModel()
            newCachedPhoto.dateCreated = photo.dateCreated
            newCachedPhoto.filePath = photo.filePath
            newCachedPhoto.isDeepSearched = true
            newCachedPhoto.isHearted = photo.isHearted
//            newCachedPhoto.contents = contents
            
    //        alreadyCached.append(newCachedPhoto)
            
            if let origIndex = photos.firstIndex(of: photo) {
                photos[origIndex] = newCachedPhoto
            } else {
                print("ERROR!!!!!!")
            }
            dispatchSemaphore.signal()
            dispatchGroup.leave()
            
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

        let newCachedPhoto = EditableHistoryModel()
        newCachedPhoto.dateCreated = photo.dateCreated
        newCachedPhoto.filePath = photo.filePath
        newCachedPhoto.isDeepSearched = true
        newCachedPhoto.isHearted = photo.isHearted
        newCachedPhoto.contents = contents
        
//        alreadyCached.append(newCachedPhoto)
        
        if let origIndex = photos.firstIndex(of: photo) {
            photos[origIndex] = newCachedPhoto
        } else {
            print("ERROR!!!!!!")
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

extension CachingViewController {
    
    func setUpViews() {
        
        cancelButton.layer.cornerRadius = 6
        
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
        
        
        rimView.layer.addSublayer(fillLayer)
        view.addSubview(rimView)
        rimView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 180, height: 180))
            make.center.equalToSuperview()
        }
        
        tintView.frame = CGRect(x: 10, y: 10, width: 160, height: 160)
        tintView.layer.cornerRadius = 2
        tintView.backgroundColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 0.12)
        rimView.addSubview(tintView)
        
        
        swipeView.frame = CGRect(x: 10, y: 5, width: 10, height: 170)
        swipeView.backgroundColor = UIColor(hexString: "00aeef")
        swipeView.layer.cornerRadius = 5
        rimView.addSubview(swipeView)
        
        
        
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
        view.bringSubviewToFront(cancelButton)
        
        
        cancelImageView.layer.cornerRadius = 4
        
        
        keepButton.layer.cornerRadius = 6
        discardButton.layer.cornerRadius = 6
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        
        numberCachedLabel.text = "0/\(photos.count) photos cached"
        
    }
}
