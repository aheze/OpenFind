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
import RealmSwift

protocol ReturnCachedPhotos: class {
    func giveCachedPhotos(photos: [EditableHistoryModel], popup: String)
}
class CachingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DoneAnimatingSEK {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Cancel cache
    
    
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var count = 0
    
    let rimView = UIView()
    let tintView = UIView()
    
    
    @IBAction func keepButtonPressed(_ sender: Any) {
        keepAlreadyCached()
    }
    @IBAction func discardButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        animateChange(toCancel: false)
    }
    
    
    
    @IBOutlet weak var baseView: UIView!
    
    
    var aspectRatioWidthOverHeight : CGFloat = 0
    
    var photos = [EditableHistoryModel]()
    var alreadyCachedPhotos = [EditableHistoryModel]()
    
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "taskQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    var statusOk = true ///OK = Running, no cancel
    
    
    var isResuming = false
    
    private var gradient: CAGradientLayer!
    private var newGrad:CAGradientLayer!
    
    @IBOutlet weak var cancelButton: UIButton!
    var presentingCancelPrompt = false
    
    weak var finishedCache: ReturnCachedPhotos?
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("dismiss?")
        statusOk = false
        
        let cancelling = NSLocalizedString("cancelling", comment: "CachingViewController def=Cancelling...")
        cancelButton.setTitle(cancelling, for: .normal)
        
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
        setUpViews()
        cancelView.isHidden = true
        backButton.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func doneAnimating() {
        startFinding()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.async {
            let frameDiff = (self.collectionView.frame.size.height - 140) / 2
            self.collectionView.contentInset.top = frameDiff
            self.collectionView.contentInset.bottom = frameDiff
            self.collectionView.contentInsetAdjustmentBehavior = .never
            let startInd = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: startInd, at: .centeredVertically, animated: true)
        }
    }
    
    func animateChange(toCancel: Bool) {
        if toCancel == true {
            self.cancelView.isHidden = false
            self.backButton.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.baseView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.cancelView.transform = CGAffineTransform.identity
                
                self.baseView.alpha = 0
                self.cancelView.alpha = 1
                self.backButton.alpha = 1
                
                self.rimView.alpha = 0
                self.tintView.alpha = 0
                self.activityIndicator.alpha = 0
                //                self.swipeView.alpha = 0
                
            }, completion: { _ in
                self.baseView.isHidden = true
                
                self.rimView.isHidden = true
                self.tintView.isHidden = true
                self.activityIndicator.isHidden = true
                //                self.swipeView.isHidden = true
            })
            
        } else {
            self.baseView.isHidden = false
            self.rimView.isHidden = false
            self.tintView.isHidden = false
            self.activityIndicator.isHidden = false
            //            self.swipeView.isHidden = false
            
            self.statusOk = true
            
            let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
            cancelButton.setTitle(cancel, for: .normal)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.baseView.transform = CGAffineTransform.identity
                self.cancelView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                
                self.baseView.alpha = 1
                self.cancelView.alpha = 0
                self.backButton.alpha = 0
                
                self.rimView.alpha = 1
                self.tintView.alpha = 1
                self.activityIndicator.alpha = 1
                //                self.swipeView.alpha = 1
                
                
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
        
        let filePath = historyModel.filePath
        let finalUrl = folderURL.appendingPathComponent(filePath)
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.imageView.sd_imageTransition = .fade
        cell.imageView.sd_setImage(with: finalUrl)
        
        
        return cell
    }
    
    
}
extension CachingViewController {
    
    func keepAlreadyCached() {
        DispatchQueue.main.async {
            
            self.finishedCache?.giveCachedPhotos(photos: self.alreadyCachedPhotos, popup: "Keep")
            SwiftEntryKit.dismiss()
        }
    }
    func finishedFind() {
        DispatchQueue.main.async {
            
            self.cancelButton.isEnabled = false
            
            self.finishedCache?.giveCachedPhotos(photos: self.alreadyCachedPhotos, popup: "Finished")
            SwiftEntryKit.dismiss()
        }
        
    }
    func finishedCancelling() {
        
        var newLabel = ""
        if count == 1 {
            let onePhotoHasAlreadyBeenCachedWouldYouKeep = NSLocalizedString("onePhotoHasAlreadyBeenCachedWouldYouKeep", comment: "CachingViewController def=1 photo has already been cached.\nWould you like to keep its cache?")
            newLabel = onePhotoHasAlreadyBeenCachedWouldYouKeep
            //            newLabel = """
            //            1 photo has already been cached.
            //            Would you like to keep its cache?
            //            """
        } else {
            let xPhotosHaveAlreadyBeenCachedWouldYouKeep = NSLocalizedString("%d photosHaveAlreadyBeenCachedWouldYouKeep", comment: "CachingViewController def=x photos have already been cached.\nWould you like to keep its cache?")
            
            let string = String.localizedStringWithFormat(xPhotosHaveAlreadyBeenCachedWouldYouKeep, count)
            
            newLabel = string
            //            newLabel = """
            //            \(count) photos have already been cached.
            //            Would you like to keep their caches?
            //            """
        }
        cancelLabel.text = newLabel
        animateChange(toCancel: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCancel" {
            
            if let cacheController = segue.destination as? CachingCancelController {
                cacheController.folderURL = folderURL
                cacheController.totalPhotos = photos
                cacheController.view.layer.cornerRadius = 10
            }
        }
    }
    
    func startFinding() {
        
        dispatchQueue.async {
            self.count = 0
            var number = 0
            for photo in self.photos {
                if self.statusOk == true {
                    number += 1
                    let indP = IndexPath(item: number - 1, section: 0)
                    DispatchQueue.main.async {
                        self.collectionView.scrollToItem(at: indP, at: .centeredVertically, animated: true)
                    }
                    if !photo.isDeepSearched {
                        self.dispatchGroup.enter()
                        let photoUrl = self.folderURL.appendingPathComponent(photo.filePath)
                        //                        guard let photoUrl = URL(string: "\(self.folderURL)\(photo.filePath)") else { print("WRONG URL!!!!"); return }
                        let request = VNRecognizeTextRequest { request, error in
                            self.handleFastDetectedText(request: request, error: error, photo: photo)
                        }
                        request.recognitionLevel = .accurate
                        request.recognitionLanguages = ["en_GB"]
                        let imageRequestHandler = VNImageRequestHandler(url: photoUrl, orientation: .up)
                        
                        request.progressHandler = { (request, value, error) in
                            print("Progress: \(value)")
                        }
                        do {
                            try imageRequestHandler.perform([request])
                        } catch let error {
                            print("Error: \(error)")
                        }
                        
                        self.dispatchSemaphore.wait()
                    } else {
                        self.count += 1
                        DispatchQueue.main.async {
                            let xSlashxPhotosCached = NSLocalizedString("%d Slash %d PhotosCached", comment: "CachingViewController def=x/x photos cached")
                            let string = String.localizedStringWithFormat(xSlashxPhotosCached, self.count, self.photos.count)
                            
//                            self.numberCachedLabel.text = "\(self.count)/\(self.photos.count) photos cached"
                            self.numberCachedLabel.text = string
                        }
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
        
        let newCachedPhoto = EditableHistoryModel()
        newCachedPhoto.dateCreated = photo.dateCreated
        newCachedPhoto.filePath = photo.filePath
        newCachedPhoto.isDeepSearched = true
        newCachedPhoto.isHearted = photo.isHearted
        
        if let origIndex = photos.firstIndex(of: photo) {
            photos[origIndex].isDeepSearched = true
        } else {
            print("ERROR!!!!!!")
        }
        count += 1
        DispatchQueue.main.async {
            self.numberCachedLabel.text = "\(self.count)/\(self.photos.count) photos cached"
        }
        
        guard let results = request?.results, results.count > 0 else {
            print("no results")
            alreadyCachedPhotos.append(newCachedPhoto)
            dispatchSemaphore.signal()
            dispatchGroup.leave()
            
            return
        }
        
        var contents = [EditableSingleHistoryContent]()
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    
                    let origX = observation.boundingBox.origin.x
                    let origY = 1 - observation.boundingBox.minY
                    let origWidth = observation.boundingBox.width
                    let origHeight = observation.boundingBox.height
                    
                    let singleContent = EditableSingleHistoryContent()
                    singleContent.text = text.string
                    singleContent.x = origX
                    singleContent.y = origY
                    singleContent.width = origWidth
                    singleContent.height = origHeight
                    contents.append(singleContent)
                }
            }
            
        }
        
        newCachedPhoto.contents = contents
        
        alreadyCachedPhotos.append(newCachedPhoto)
        dispatchSemaphore.signal()
        dispatchGroup.leave()
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
        tintView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.6823529412, blue: 0.937254902, alpha: 0.25)
        rimView.addSubview(tintView)
        
        gradient = CAGradientLayer()
        gradient.frame = collectionSuperview.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.16, 0.84, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        collectionSuperview.layer.mask = gradient
        collectionSuperview.layer.masksToBounds = true
        
        view.clipsToBounds = true
        view.bringSubviewToFront(cancelButton)
        
        
        cancelImageView.layer.cornerRadius = 4
        if let firstPhoto = photos.first {
            let finalUrl = folderURL.appendingPathComponent(firstPhoto.filePath)
            cancelImageView.sd_imageTransition = .fade
            cancelImageView.sd_setImage(with: finalUrl)
        }
        
        
        keepButton.layer.cornerRadius = 6
        discardButton.layer.cornerRadius = 6
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        
        numberCachedLabel.text = "0/\(photos.count) photos cached"
        
        baseView.bringSubviewToFront(activityIndicator)
    }
}

extension String {
    func getImageFromDir() -> UIImage? {
        
        if let fileURL = URL(string: self) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Not able to load image")
            }
        }
        return nil
    }
}
