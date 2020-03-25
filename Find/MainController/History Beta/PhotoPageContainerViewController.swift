//
//  PhotoPageContainerViewController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}

protocol ChangedSearchTermsFromZoom: class {
    func pause(pause: Bool)
    func returnTerms(stringToListR: [String: EditableFindList], currentSearchFindListR: EditableFindList, currentListsSharedFindListR: EditableFindList, currentSearchAndListSharedFindListR: EditableFindList, currentMatchStringsR: [String], matchToColorsR: [String: [CGColor]])
    func startedEditing(start: Bool)
}

protocol ZoomStateChanged: class {
    func changedState(type: String)
}

protocol ZoomDeletedPhoto: class {
    func deletedPhoto(photoIndex: Int)
}

class PhotoPageContainerViewController: UIViewController, UIGestureRecognizerDelegate {

    
//    @IBOutlet weak var xButtonView: UIImageView!
    
    
    @IBOutlet weak var xButton: UIButton!
    @IBAction func xButtonPressed(_ sender: Any) {
        self.currentViewController.scrollView.isScrollEnabled = false
        self.transitionController.isInteractive = false
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func findPressed(_ sender: Any) {
    }
    
    @IBAction func heartPressed(_ sender: Any) {
    }
    
    @IBAction func cachePressed(_ sender: Any) {
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
            
            //        var goRight = true
            let oldCount = self.photoModels.count - 1
            self.photoModels.remove(at: index)
            self.deletedPhoto?.deletedPhoto(photoIndex: index)
            
            var newIndex = 0
            
                    
//            print("OLD INDEX: \(index)")
//            print("OLD COUNT: \(oldCount)")
            if index == 0 {
                ///DELETED FIRST photo
    //            goRight = false
               if self.photoModels.count == 0 {
                   print("DELETED LAST PHOTO")
                   self.currentViewController.scrollView.isScrollEnabled = false
                   self.transitionController.isInteractive = false
                   self.transitionController.deletedLast = true
                   self.dismiss(animated: true, completion: nil)
//                    self.dismiss(animated: true, completion: nil)
               } else {
                   newIndex = index
                   vc.delegate = self
                   vc.imageSize = self.photoSize
                   let filePath = self.photoModels[newIndex].filePath
                   let urlString = URL(string: "\(self.folderURL)\(filePath)")
                   vc.url = urlString
                   vc.index = newIndex
                   self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
                   let viewControllers = [ vc ]
//                   self.pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: nil)
                    UIView.animate(withDuration: 0.25, animations: {
                        self.currentViewController.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        self.currentViewController.view.alpha = 0
                    }) { _ in
                       self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
                    }
                }
                
//               }
                
            
            } else {
                newIndex = index - 1
                vc.delegate = self
                vc.imageSize = self.photoSize
                let filePath = self.photoModels[newIndex].filePath
                let urlString = URL(string: "\(self.folderURL)\(filePath)")
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
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func morePressed(_ sender: Any) {
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
//    var currentSection = 0
//    var nextIndex: Int?
//    var newNextIndex = -1
    
    
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
      
        backBlurView.layer.cornerRadius = 6
        backBlurView.clipsToBounds = true
        
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
            let filePath = self.findModels[self.currentIndex].photo.filePath
            urlString = URL(string: "\(folderURL)\(filePath)")
        } else {
            let filePath = self.photoModels[self.currentIndex].filePath
            urlString = URL(string: "\(folderURL)\(filePath)")
        }
        
        vc.url = urlString
        vc.index = currentIndex
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        let viewControllers = [ vc ]
            
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        if cameFromFind {
            blurView.isHidden = true
            
            var attributes = EKAttributes.bottomFloat
            attributes.entryBackground = .color(color: .white)
            attributes.entranceAnimation = .translation
            attributes.exitAnimation = .translation
            attributes.displayDuration = .infinity
            attributes.positionConstraints.size.height = .constant(value: 60)
            attributes.statusBar = .light
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
            attributes.roundCorners = .all(radius: 5)
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.35, radius: 6, offset: .zero))
            
            let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
            let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
            attributes.positionConstraints.keyboardRelation = keyboardRelation
            
            let customView = FindBar()
            
//            customView.returnTerms = self
            SwiftEntryKit.display(entry: customView, using: attributes)
        } else {
            blurView.layer.cornerRadius = 10
            blurView.clipsToBounds = true
            if photoModels[currentIndex].isHearted == true {
                let newImage = UIImage(systemName: "heart.fill")
                heartButton.setImage(newImage, for: .normal)
            } else {
                let newImage = UIImage(systemName: "heart")
                heartButton.setImage(newImage, for: .normal)
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
//                UIView.animate(withDuration: 0.4, delay: 0.6, options: [], animations: {
//                    self.findButton.alpha = 1
//                    self.heartButton.alpha = 1
//                    self.deleteButton.alpha = 1
//                    self.shareButton.alpha = 1
//                }) { _ in
//                    self.findButton.isHidden = false
//                    self.heartButton.isHidden = false
//                    self.deleteButton.isHidden = false
//                    self.shareButton.isHidden = false
//                }
            }
        default:
//            print("default")
            
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
//                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
//                    self.findButton.alpha = 0
//                    self.heartButton.alpha = 0
//                    self.deleteButton.alpha = 0
//                    self.shareButton.alpha = 0
//                }) { _ in
//                    self.findButton.isHidden = true
//                    self.heartButton.isHidden = true
//                    self.deleteButton.isHidden = true
//                    self.shareButton.isHidden = true
//                }
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
            }, completion: { completed in
                self.xButton.isHidden = true
                self.blurView.isHidden = true
            })
            
        } else {
            if !cameFromFind {
                blurView.isHidden = false
                UIView.animate(withDuration: 0.25,
                               animations: {
                                self.blurView.alpha = 1
                }, completion: nil)
                
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
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.delegate = self
        vc.imageSize = photoSize
        var urlString = URL(string: "")
        if cameFromFind {
            let filePath = self.findModels[self.currentIndex - 1].photo.filePath
            urlString = URL(string: "\(folderURL)\(filePath)")
        } else {
            let filePath = self.photoModels[self.currentIndex - 1].filePath
            urlString = URL(string: "\(folderURL)\(filePath)")
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
        
        
        var urlString = URL(string: "")
        if cameFromFind {
            let filePath = self.findModels[self.currentIndex + 1].photo.filePath
            urlString = URL(string: "\(folderURL)\(filePath)")
        } else {
            let filePath = self.photoModels[self.currentIndex + 1].filePath
            urlString = URL(string: "\(folderURL)\(filePath)")
        }
        
        vc.url = urlString
        guard let zoomVC = viewController as? PhotoZoomViewController else { print("NONONONO"); return nil}
        vc.index = zoomVC.index + 1
        
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let currentVC = currentViewController
            let index = currentVC.index
            print("INDEX: \(index)")
            currentIndex = index
            
        }
        previousViewControllers.forEach { vc in
            let zoomVC = vc as! PhotoZoomViewController
            zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
        }

        self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)

        if !cameFromFind {
            if self.photoModels[self.currentIndex].isHearted == true {
                let newImage = UIImage(systemName: "heart.fill")
                heartButton.setImage(newImage, for: .normal)
            } else {
                let newImage = UIImage(systemName: "heart")
                heartButton.setImage(newImage, for: .normal)
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
        return self.currentViewController.scrollView.convert(self.currentViewController.imageView.frame, to: self.currentViewController.view)
    }
}
