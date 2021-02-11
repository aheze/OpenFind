//
//  CachingViewController.swift
//  Find
//
//  Created by Zheng on 3/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImagePhotosPlugin
import SwiftEntryKit
import Vision
import RealmSwift
import Photos

enum CacheReturn {
    case completedAll
    case keptSome
}
protocol ReturnCachedPhotos: class {
    func giveCachedPhotos(photos: [FindPhoto], returnResult: CacheReturn)
}
class CachingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Cancel cache
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var baseView: UIView!
    let rimView = UIView()
    let tintView = UIView()
    
    @IBOutlet weak var numberCachedLabel: UILabel!
    @IBOutlet weak var collectionSuperview: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        CachingFinder.statusOk = false
        let cancelling = NSLocalizedString("cancelling", comment: "CachingViewController def=Cancelling...")
        cancelButton.setTitle(cancelling, for: .normal)
    }
    @IBAction func keepButtonPressed(_ sender: Any) {
        keepAlreadyCached()
    }
    @IBAction func discardButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        animateChange(toCancel: false)
    }
    
    let screenScale = UIScreen.main.scale /// for photo thumbnail
    let realm = try! Realm()
    var getRealRealmModel: ((EditableHistoryModel) -> HistoryModel?)? /// get real realm managed object
    
    // MARK: Photos to cache
    var photosToCache = [FindPhoto]()
    
    private var gradient: CAGradientLayer!
    private var newGrad: CAGradientLayer!
    
    @IBOutlet weak var cancelButton: UIButton!
    var presentingCancelPrompt = false
    
    weak var finishedCache: ReturnCachedPhotos?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = collectionSuperview.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
                
            }, completion: { _ in
                self.baseView.isHidden = true
                
                self.rimView.isHidden = true
                self.tintView.isHidden = true
                self.activityIndicator.isHidden = true
            })
            
        } else {
            self.baseView.isHidden = false
            self.rimView.isHidden = false
            self.tintView.isHidden = false
            self.activityIndicator.isHidden = false
            
            CachingFinder.statusOk = true
            
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
                
            }, completion: { _ in
                self.cancelView.isHidden = true
                self.backButton.isHidden = true
                self.startFinding()
            })
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosToCache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cacheCellid", for: indexPath) as! CacheCell
        
        let findPhoto = photosToCache[indexPath.item]
        
        if let url = NSURL.sd_URL(with: findPhoto.asset) {
            let cellLength = cell.bounds.width
            let imageLength = cellLength * (screenScale + 1)

            cell.imageView.sd_imageTransition = .fade
            cell.imageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue, .imageThumbnailPixelSize : CGSize(width: imageLength, height: imageLength)])
        }
        return cell
    }
    
    
}
extension CachingViewController {
    
    func keepAlreadyCached() {
        DispatchQueue.main.async {
            self.finishedCache?.giveCachedPhotos(photos: CachingFinder.alreadyCachedPhotos, returnResult: .keptSome)
            SwiftEntryKit.dismiss()
            CachingFinder.resetState()
        }
    }
    func finishedFind() {
        DispatchQueue.main.async {
            self.cancelButton.isEnabled = false
            self.finishedCache?.giveCachedPhotos(photos: CachingFinder.alreadyCachedPhotos, returnResult: .completedAll)
            SwiftEntryKit.dismiss()
            CachingFinder.resetState()
        }
    }
    func finishedCancelling() {
        var newLabel = ""
        if CachingFinder.numberCached == 1 {
            let onePhotoHasAlreadyBeenCachedWouldYouKeep = NSLocalizedString("onePhotoHasAlreadyBeenCachedWouldYouKeep", comment: "CachingViewController def=1 photo has already been cached.\nWould you like to keep its cache?")
            newLabel = onePhotoHasAlreadyBeenCachedWouldYouKeep
        } else {
            let xPhotosHaveAlreadyBeenCachedWouldYouKeep = NSLocalizedString("%d photosHaveAlreadyBeenCachedWouldYouKeep", comment: "CachingViewController def=x photos have already been cached.\nWould you like to keep its cache?")
            
            let string = String.localizedStringWithFormat(xPhotosHaveAlreadyBeenCachedWouldYouKeep, CachingFinder.numberCached)
            newLabel = string
        }
        cancelLabel.text = newLabel
        animateChange(toCancel: true)
        
    }
    
    func startFinding() {
        activityIndicator.startAnimating()
        CachingFinder.getRealRealmModel = self.getRealRealmModel
        
        CachingFinder.startedFindingFromNewPhoto = { [weak self] photoIndex in
            guard let self = self else { return }
            let indexPath = IndexPath(item: photoIndex - 1, section: 0)
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        }
        CachingFinder.completedAnotherPhoto = { [weak self] numberCached in
            guard let self = self else { return }
            
            let xSlashxPhotosCached = NSLocalizedString("%d Slash %d PhotosCached", comment: "CachingViewController def=x/x photos cached")
            let string = String.localizedStringWithFormat(xSlashxPhotosCached, numberCached, CachingFinder.photosToCache.count)
            DispatchQueue.main.async {
                self.numberCachedLabel.text = string
            }
        }
        CachingFinder.finishedCancelling = { [weak self] in
            guard let self = self else { return }
            
            self.finishedCancelling()
        }
        
        CachingFinder.finishedFind = { [weak self] in
            guard let self = self else { return }
            
            self.finishedFind()
        }
        
        CachingFinder.load(with: photosToCache)
        CachingFinder.startFinding()
    }
}
extension CachingViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    
    func setupViews() {
        
        cancelButton.layer.cornerRadius = 6
        
        let bigRect = CGRect(x: 0, y: 0, width: 180, height: 180)
        
        let pathBigRect = UIBezierPath(roundedRect: bigRect, cornerRadius: 4)
        let smallRect = CGRect(x: 10, y: 10, width: 160, height: 160)
        
        let pathSmallRect = UIBezierPath(roundedRect: smallRect, cornerRadius: 2)
        
        pathBigRect.append(pathSmallRect)
        pathBigRect.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = pathBigRect.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        
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
        if let firstPhoto = photosToCache.first {
            
            if let url = NSURL.sd_URL(with: firstPhoto.asset) {
                let boundsLength = cancelImageView.bounds.width
                let imageLength = boundsLength * (screenScale + 1)

                cancelImageView.sd_imageTransition = .fade
                cancelImageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue, .imageThumbnailPixelSize : CGSize(width: imageLength, height: imageLength)])
                
            }
        }
        
        
        keepButton.layer.cornerRadius = 6
        discardButton.layer.cornerRadius = 6
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        
        let xSlashxPhotosCached = NSLocalizedString("%d Slash %d PhotosCached", comment: "CachingViewController def=x/x photos cached")
        let string = String.localizedStringWithFormat(xSlashxPhotosCached, 0, photosToCache.count)
        numberCachedLabel.text = string

        baseView.bringSubviewToFront(activityIndicator)
    }
}
