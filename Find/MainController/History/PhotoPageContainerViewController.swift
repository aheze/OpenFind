//
//  PhotoPageContainerViewController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SPAlert

protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}
protocol ChangedSearchTermsFromZoom: class {
//    func pause(pause: Bool)
    func returnTerms(matchToColorsR: [String: [CGColor]])
    func pressedReturn()
}
protocol ZoomStateChanged: class {
    func changedState(type: String, index: Int)
}
protocol ZoomCached: class {
    func cached(cached: Bool, photo: EditableHistoryModel, index: Int)
}

protocol ZoomDeletedPhoto: class {
    func deletedPhoto(photoIndex: Int)
}
protocol GiveFindbarMatchNumber: class {
    func howMany(number: Int, inCache: Bool, noSearchTerms: Bool)
}

class PhotoPageContainerViewController: UIViewController, UIGestureRecognizerDelegate {

//    var currentMatchStrings = [String]()
    var highlightColor = "00aeef"
    var matchToColors = [String: [CGColor]]()
    
    var goDirectlyToFind = false
    
    
    @IBOutlet weak var xButton: UIButton!
    @IBAction func xButtonPressed(_ sender: Any) {
        self.currentViewController.scrollView.isScrollEnabled = false
        self.transitionController.isInteractive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var doneFindingBlurView: UIVisualEffectView!
    
    @IBOutlet weak var doneFinding: UIButton!
    
    @IBAction func doneFindingPressed(_ sender: Any) {
        matchToColors.removeAll()
        changedTerms?.returnTerms(matchToColorsR: matchToColors)
        SwiftEntryKit.dismiss()
        
        findingNow = false
        UIView.animate(withDuration: 0.2, animations: {
            self.doneFindingBlurView.alpha = 0
        }) { _ in
            self.doneFindingBlurView.isHidden = true
        }
    }
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var findingNow = false
    
    weak var changeModel: ZoomStateChanged?
    weak var doneAnimatingSEK: DoneAnimatingSEK?
    weak var changeCache: ZoomCached?
    weak var giveNumber: GiveFindbarMatchNumber?
    
    
    weak var changeFindbar: ChangeFindBar?
    
    var deviceSize = screenBounds.size
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBAction func findPressed(_ sender: Any) {
        pressFind()
    }
    
    @IBAction func heartPressed(_ sender: Any) {
        if photoModels[currentIndex].isHearted == true {
            photoModels[currentIndex].isHearted = false
            let newImage = UIImage(systemName: "heart")
            heartButton.setImage(newImage, for: .normal)
            heartButton.tintColor = UIColor(hexString: "5287B6")
            changeModel?.changedState(type: "Unheart", index: currentIndex)
        } else {
            photoModels[currentIndex].isHearted = true
            let newImage = UIImage(systemName: "heart.fill")
            heartButton.setImage(newImage, for: .normal)
            heartButton.tintColor = UIColor(named: "FeedbackGradientRight")
            changeModel?.changedState(type: "Heart", index: currentIndex)
        }
    }
    
    @IBAction func cachePressed(_ sender: Any) {
        if photoModels[currentIndex].isDeepSearched == false {
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.entryBackground = .color(color: .white)
            attributes.screenInteraction = .absorbTouches
            attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(300))
//            attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
            attributes.positionConstraints.maxSize = .init(width: .constant(value: 450), height: .constant(value: 550))
            attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
            attributes.lifecycleEvents.didAppear = {
                self.doneAnimatingSEK?.doneAnimating()
            }
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
            
            let singleItem = photoModels[currentIndex]
            
            let newPhoto = EditableHistoryModel()
            newPhoto.filePath = singleItem.filePath
            newPhoto.dateCreated = singleItem.dateCreated
            newPhoto.isHearted = singleItem.isHearted
            newPhoto.isDeepSearched = singleItem.isDeepSearched
            let editablePhotoArray = [newPhoto]
            
            cacheController.folderURL = folderURL
            cacheController.photos = editablePhotoArray
            cacheController.finishedCache = self
            self.doneAnimatingSEK = cacheController
            cacheController.view.layer.cornerRadius = 10
            
            
            SwiftEntryKit.display(entry: cacheController, using: attributes)
            
        } else { ///UNCACHE
            
            let alert = UIAlertController(title: "Delete this photo's cache?", message: "Caching again will take a while...", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
                let tempModel = EditableHistoryModel()
                self.changeCache?.cached(cached: false, photo: tempModel, index: self.currentIndex)
                self.cacheButton.setImage(UIImage(named: "NotCachedThin"), for: .normal)
                self.cacheButton.tintColor = UIColor(hexString: "5287B6")
                self.photoModels[self.currentIndex].isDeepSearched = false
                
                let alertView = SPAlertView(title: "Deleted this photo's cache!", message: "Tap to dismiss", preset: SPAlertPreset.done)
                alertView.duration = 2.6
                alertView.present()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = cacheButton
                popoverController.sourceRect = cacheButton.bounds
            }
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
//            if let nextPage = pageViewController(self, viewControllerAfter: currentViewController) {
//                pageViewController.setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
//            }
//        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
//        let currentIndex = currentViewController
        
        let alert = UIAlertController(title: "Delete photo?", message: "This action can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
            
            let zoomVC = self.currentViewController
            let index = zoomVC.index
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
            
            self.photoModels.remove(at: index)
            self.deletedPhoto?.deletedPhoto(photoIndex: index)
            
            var newIndex = 0
            if index == 0 {
                ///DELETED FIRST photo
    //            goRight = false
               if self.photoModels.count == 0 {
                   print("DELETED LAST PHOTO")
                   self.currentViewController.scrollView.isScrollEnabled = false
                   self.transitionController.isInteractive = false
                   self.transitionController.deletedLast = true
                   self.dismiss(animated: true, completion: nil)
               } else {
                    newIndex = index
                    vc.delegate = self
                    vc.imageSize = self.photoSize
                    let filePath = self.photoModels[newIndex].filePath
//                   let urlString = URL(string: "\(self.folderURL)\(filePath)")
                    let urlString = self.folderURL.appendingPathComponent(filePath)
                    vc.url = urlString
                    vc.index = newIndex
                    self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
                    let viewControllers = [ vc ]
                    UIView.animate(withDuration: 0.25, animations: {
                        self.currentViewController.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        self.currentViewController.view.alpha = 0
                    }) { _ in
                       self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
                    }
                }
            } else {
                newIndex = index - 1
                vc.delegate = self
                vc.imageSize = self.photoSize
                let filePath = self.photoModels[newIndex].filePath
//                let urlString = URL(string: "\(self.folderURL)\(filePath)")
                let urlString = self.folderURL.appendingPathComponent(filePath)
                vc.url = urlString
                vc.index = newIndex
                self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
                let viewControllers = [ vc ]
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.currentViewController.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    self.currentViewController.view.alpha = 0
                }) { _ in
                   self.pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: nil)
                }
            }
            
            self.currentIndex = newIndex
            self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = deleteButton
            popoverController.sourceRect = deleteButton.bounds
       }
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        
        let currentModel = photoModels[currentIndex]
//        let filePath = folderURL.appendingPathComponent(currentModel.filePath)
//        if let image = filePath.loadImageFromDocumentDirectory() {
            
        let shareObject = HistorySharing(filePath: currentModel.filePath, folderURL: folderURL)
        let activityViewController = UIActivityViewController(activityItems: [shareObject], applicationActivities: nil)
        let tempController = UIViewController()
        tempController.modalPresentationStyle = .overFullScreen
        activityViewController.completionWithItemsHandler = { [weak tempController] _, _, _, _ in
            if let presentingViewController = tempController?.presentingViewController {
                presentingViewController.dismiss(animated: true, completion: nil)
            } else {
                tempController?.dismiss(animated: true, completion: nil)
            }
        }
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: shareButton.frame.width, height: shareButton.frame.width)
            popoverController.sourceView = shareButton
//                popoverController.permittedArrowDirections = .up
        }
        present(tempController, animated: true) { [weak tempController] in
            tempController?.present(activityViewController, animated: true, completion: nil)
        }
//        }

    }
    
    @IBOutlet weak var backBlurView: UIVisualEffectView!
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)

    
    enum ScreenMode {
        case full, normal
    }
    var currentMode: ScreenMode = .normal
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    weak var deletedPhoto: ZoomDeletedPhoto?
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: PhotoZoomViewController {
        return self.pageViewController.viewControllers![0] as! PhotoZoomViewController
    }
    
    //var photos = [UIImage]()
    
    //MARK: FROM FIND
    var cameFromFind = false
    var findModels = [FindModel]()
    var changedTerms: ChangedSearchTermsFromZoom?

    var photoModels = [EditableHistoryModel]()
    var currentIndex = 0
    
    var photoSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            print("SET")
            print(photoSize)
        }
    }

    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGestureRecognizer: UITapGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOAD!!! \(view.bounds)")
        backBlurView.layer.cornerRadius = 6
        backBlurView.clipsToBounds = true
        
        doneFindingBlurView.layer.cornerRadius = 6
        doneFindingBlurView.clipsToBounds = true
        
        doneFindingBlurView.isHidden = true
        doneFindingBlurView.alpha = 0
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.panGestureRecognizer.delegate = self
        self.pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
        
        self.singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapWith(gestureRecognizer:)))
        self.pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.delegate = self
        vc.imageSize = photoSize
        var urlString = URL(string: "")
        if cameFromFind {
            
            let model = self.findModels[self.currentIndex]
            let filePath = model.photo.filePath
            
            urlString = folderURL.appendingPathComponent(filePath)
//            urlString = URL(string: "\(folderURL)\(filePath)")
            
            vc.matchToColors = matchToColors
            
            print("MATCHS: \(matchToColors)")
            vc.highlights = model.components
            vc.cameFromFind = true
            
        } else {
            vc.photoComp = self.photoModels[self.currentIndex]
            let filePath = self.photoModels[self.currentIndex].filePath
//            urlString = URL(string: "\(folderURL)\(filePath)")
            urlString = folderURL.appendingPathComponent(filePath)
            self.changedTerms = vc
            vc.cameFromFind = false
            vc.returnNumber = self
        }
        
        vc.folderURL = folderURL
        vc.url = urlString
        vc.index = currentIndex
        
        
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        let viewControllers = [ vc ]
            
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        if cameFromFind {
            blurView.isHidden = true
        } else {
            blurView.layer.cornerRadius = 10
            blurView.clipsToBounds = true
            if photoModels[currentIndex].isHearted == true {
                let newImage = UIImage(systemName: "heart.fill")
                heartButton.setImage(newImage, for: .normal)
                heartButton.tintColor = UIColor(named: "FeedbackGradientRight")
            } else {
                let newImage = UIImage(systemName: "heart")
                heartButton.setImage(newImage, for: .normal)
                heartButton.tintColor = UIColor(hexString: "5287B6")
            }
            if photoModels[currentIndex].isDeepSearched == true {
                cacheButton.setImage(UIImage(named: "YesCachedThin"), for: .normal)
                cacheButton.tintColor = UIColor(named: "FeedbackGradientRight")
            } else {
                cacheButton.setImage(UIImage(named: "NotCachedThin"), for: .normal)
                cacheButton.tintColor = UIColor(hexString: "5287B6")
            }
            
            if goDirectlyToFind {
                pressFind()
            }
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            
            var velocityCheck : Bool = false
            
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer == self.currentViewController.scrollView.panGestureRecognizer {
            if self.currentViewController.scrollView.contentOffset.y == 0 {
                return true
            }
        }
        
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            print("Dismissing")
            self.currentViewController.scrollView.isScrollEnabled = false
            self.transitionController.isInteractive = true
            //let _ = self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        case .ended:
//            print("ended")
            if self.transitionController.isInteractive {
                self.currentViewController.scrollView.isScrollEnabled = true
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
    
    @objc func didSingleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if self.currentMode == .full {
            changeScreenMode(to: .normal)
            self.currentMode = .normal
        } else {
            changeScreenMode(to: .full)
            self.currentMode = .full
        }

    }
    
    func changeScreenMode(to: ScreenMode) {
        if to == .full {
            if !cameFromFind {
                UIView.animate(withDuration: 0.25,
                               animations: {
                                self.blurView.alpha = 0
                }, completion: { completed in
                    self.blurView.isHidden = true
                })
            }
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.view.backgroundColor = .black
                            self.xButton.alpha = 0
                            self.backBlurView.alpha = 0
                            if self.findingNow {
                                self.doneFindingBlurView.alpha = 0
                            }
                            
            }, completion: { completed in
                self.xButton.isHidden = true
                self.blurView.isHidden = true
                if self.findingNow {
                    self.doneFindingBlurView.isHidden = true
                }
            })
            
        } else {
            if !cameFromFind {
                blurView.isHidden = false
                UIView.animate(withDuration: 0.25,
                               animations: {
                                self.blurView.alpha = 1
                }, completion: nil)
                
            }
            if self.findingNow {
                self.doneFindingBlurView.isHidden = false
            }
            self.xButton.isHidden = false
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.xButton.alpha = 1
                            if #available(iOS 13.0, *) {
                                self.view.backgroundColor = .systemBackground
                            } else {
                                self.view.backgroundColor = .white
                            }
                            if self.findingNow {
                                self.doneFindingBlurView.alpha = 1
                            }
                            self.backBlurView.alpha = 1
            }, completion: { completed in
            })
        }
    }
    
}

extension PhotoPageContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == 0 {
            return nil
        }
        print("NEXTTTT!!! \(view.bounds)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.delegate = self
        vc.imageSize = photoSize
        vc.folderURL = folderURL
//        vc.highlightColor = highlightColor
        var urlString = URL(string: "")
        if cameFromFind {
            let model = self.findModels[self.currentIndex - 1]
            let filePath = model.photo.filePath
//            urlString = URL(string: "\(folderURL)\(filePath)")
            urlString = folderURL.appendingPathComponent(filePath)
            vc.matchToColors = matchToColors
            vc.highlights = model.components
            vc.cameFromFind = true
        } else {
            let filePath = self.photoModels[self.currentIndex - 1].filePath
//            urlString = URL(string: "\(folderURL)\(filePath)")
            urlString = folderURL.appendingPathComponent(filePath)
            vc.photoComp = self.photoModels[self.currentIndex - 1]
            vc.cameFromFind = false
//            self.changedTerms = vc
//            changedTerms?.returnTerms(matchToColorsR: matchToColors)
        }
        
        vc.url = urlString
        guard let zoomVC = viewController as? PhotoZoomViewController else { print("NONONONO"); return nil}
        vc.index = zoomVC.index - 1
        
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if cameFromFind {
            if currentIndex == (self.findModels.count - 1) {
                return nil
            }
        } else {
            if currentIndex == (self.photoModels.count - 1) {
                return nil
            }
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.delegate = self
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        vc.imageSize = photoSize
        vc.folderURL = folderURL
//        vc.highlightColor = highlightColor
        
        var urlString = URL(string: "")
        if cameFromFind {
//            let filePath = self.findModels[self.currentIndex + 1].photo.filePath
//            urlString = URL(string: "\(folderURL)\(filePath)")
//
            let model = self.findModels[self.currentIndex + 1]
            let filePath = model.photo.filePath
//            urlString = URL(string: "\(folderURL)\(filePath)")
            urlString = folderURL.appendingPathComponent(filePath)
            vc.matchToColors = matchToColors
            vc.highlights = model.components
            vc.cameFromFind = true
        } else {
            let filePath = self.photoModels[self.currentIndex + 1].filePath
//            urlString = URL(string: "\(folderURL)\(filePath)")
            urlString = folderURL.appendingPathComponent(filePath)
            vc.photoComp = self.photoModels[self.currentIndex + 1]
            vc.cameFromFind = false
//            self.changedTerms = vc
//            changedTerms?.returnTerms(matchToColorsR: matchToColors)
        }
        
        vc.url = urlString
        guard let zoomVC = viewController as? PhotoZoomViewController else { print("NONONONO"); return nil}
        vc.index = zoomVC.index + 1
        
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentVC = currentViewController
        if completed {
            let index = currentVC.index
            currentVC.returnNumber = self
            print("INDEX: \(index)")
            currentIndex = index
        }
        previousViewControllers.forEach { vc in
            let zoomVC = vc as! PhotoZoomViewController
            zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
        }

        self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)

        if !cameFromFind {
            if completed {
                self.changedTerms = currentVC
                changedTerms?.returnTerms(matchToColorsR: matchToColors)
            }
            if photoModels[currentIndex].isHearted == true {
                let newImage = UIImage(systemName: "heart.fill")
                heartButton.setImage(newImage, for: .normal)
                heartButton.tintColor = UIColor(named: "FeedbackGradientRight")
            } else {
                let newImage = UIImage(systemName: "heart")
                heartButton.setImage(newImage, for: .normal)
                heartButton.tintColor = UIColor(hexString: "5287B6")
            }
            if photoModels[currentIndex].isDeepSearched == true {
                cacheButton.setImage(UIImage(named: "YesCachedThin"), for: .normal)
                cacheButton.tintColor = UIColor(named: "FeedbackGradientRight")
            } else {
                cacheButton.setImage(UIImage(named: "NotCachedThin"), for: .normal)
                cacheButton.tintColor = UIColor(hexString: "5287B6")
            }
            
        }
        
    }
    
}

extension PhotoPageContainerViewController: PhotoZoomViewControllerDelegate {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView) {
        if scrollView.zoomScale != scrollView.minimumZoomScale && self.currentMode != .full {
            self.changeScreenMode(to: .full)
            self.currentMode = .full
        }
    }
}

extension PhotoPageContainerViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.currentViewController.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.currentViewController.scrollView.convert(self.currentViewController.mainContentView.frame, to: self.currentViewController.view)
    }
}
extension PhotoPageContainerViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [EditableHistoryModel], popup: String) {
        
        photoModels[currentIndex].isDeepSearched = true
        
        
        cacheButton.setImage(UIImage(named: "YesCachedThin"), for: .normal)
        cacheButton.tintColor = UIColor(named: "FeedbackGradientRight")
        
        print("give")
        if popup == "Keep" {
            let alertView = SPAlertView(title: "Kept cached photos!", message: "Tap to dismiss", preset: SPAlertPreset.done)
            alertView.duration = 4
            alertView.present()
        } else if popup == "Finished" {
            let alertView = SPAlertView(title: "Caching done!", message: "Tap to dismiss", preset: SPAlertPreset.done)
            alertView.duration = 4
            alertView.present()
            
        }
        if let firstPhoto = photos.first {
            photoModels[currentIndex] = firstPhoto
            currentViewController.photoComp = firstPhoto
            changeCache?.cached(cached: true, photo: firstPhoto, index: currentIndex)
        } else {
            print("NO PHOTO>>>>!")
        }
        
    }
}

extension PhotoPageContainerViewController: ReturnSortedTerms {
    
    func hereAreCurrentLists(currentSelected: [EditableFindList], currentText: String, object: MatchesLabelObject) {
    }
    
    func returnTerms(matchToColorsR: [String : [CGColor]]) {
        matchToColors = matchToColorsR
        changedTerms?.returnTerms(matchToColorsR: matchToColorsR)
    }
    
    func pause(pause: Bool) {
    }
    
    func startedEditing(start: Bool) {
    }
    
    func pressedReturn() {
        changedTerms?.pressedReturn()
    }
    
    func triedToEdit() {
    }
    
    func triedToEditWhilePaused() {
    }
    
    
    
}
extension PhotoPageContainerViewController {
    func pressFind() {
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = .infinity
        attributes.positionConstraints.size.height = .constant(value: 60)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.roundCorners = .all(radius: 5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.35, radius: 6, offset: .zero))
        let edgeWidth = CGFloat(600)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        let customView = FindBar()
        
        customView.returnTerms = self
        customView.highlightColor = highlightColor
//        customView.
        self.giveNumber = customView
        
        self.changeFindbar = customView
        SwiftEntryKit.display(entry: customView, using: attributes)
        
        findingNow = true
        doneFindingBlurView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.doneFindingBlurView.alpha = 1
        })
    }
}

extension PhotoPageContainerViewController: ReturnHowManyMatches {
    
    func howMany(number: Int, searchInCache: Bool) {
//        howMany.
        print("photo cont.... \(number), matchCount: \(matchToColors.count)")
        if matchToColors.count == 0 {
            giveNumber?.howMany(number: number, inCache: searchInCache, noSearchTerms: true)
        } else {
            giveNumber?.howMany(number: number, inCache: searchInCache, noSearchTerms: false)
        }
    }
    
}
