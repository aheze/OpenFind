//
//  PhotoPageContainerViewController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int, sectionDidUpdate currentSection: Int)
}

class PhotoPageContainerViewController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var xButtonView: UIImageView!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    
    @IBAction func findPressed(_ sender: UIButton) {
        print("find")
    }
    
    @IBAction func heartPressed(_ sender: UIButton) {
        print("heart")
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        print("delete")
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        print("share")
    }
    
    
    enum ScreenMode {
        case full, normal
    }
    var currentMode: ScreenMode = .normal
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    
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

    var photoModels = [EditableHistoryModel]()
    var currentIndex = 0
    var currentSection = 0
    var nextIndex: Int?
    var photoSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            print("SET")
            print(photoSize)
        }
    }
    
    func drawImageViews() {
        //let findImage = StyleKitName.imageOfFind
        findButton.alpha = 0
        heartButton.alpha = 0
        deleteButton.alpha = 0
        shareButton.alpha = 0
        findButton.tintColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        heartButton.tintColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        deleteButton.tintColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        shareButton.tintColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        findButton.setImage(StyleKitName.imageOfFind, for: .normal)
        heartButton.setImage(StyleKitName.imageOfHeart, for: .normal)
        deleteButton.setImage(StyleKitName.imageOfDelete, for: .normal)
        shareButton.setImage(StyleKitName.imageOfShare, for: .normal)
        print("start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
            print("exce")
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
                self.findButton.alpha = 1
                self.heartButton.alpha = 1
                self.deleteButton.alpha = 1
                self.shareButton.alpha = 1
            }, completion: nil)
        })
        
        
    }
    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGestureRecognizer: UITapGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawImageViews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleXPress(_:)))
        xButtonView.addGestureRecognizer(tap)
        xButtonView.isUserInteractionEnabled = true
        view.bringSubviewToFront(xButtonView)
            
            self.pageViewController.delegate = self
            self.pageViewController.dataSource = self
            self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
            self.panGestureRecognizer.delegate = self
            self.pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
            
            self.singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapWith(gestureRecognizer:)))
            self.pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
            vc.delegate = self
            //vc.index = self.currentIndex
            //vc.image = self.photos[self.currentIndex]
        print("load")
        print(photoSize)
        vc.imageSize = photoSize
        
        let filePath = self.photoModels[self.currentIndex].filePath
        let urlString = URL(string: "\(folderURL)\(filePath)")
        vc.url = urlString
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        let viewControllers = [
            vc
        ]
            
            self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
    }
    
    @objc func handleXPress(_ sender: UITapGestureRecognizer? = nil) {
        print("x pressed...")
//        self.transitionController.animator.isPresenting = false
//        let tmp = self.transitionController.fromDelegate
//        self.transitionController.animator.fromDelegate = self.transitionController.toDelegate
//        self.transitionController.animator.toDelegate = tmp
        self.currentViewController.scrollView.isScrollEnabled = false
        self.transitionController.isInteractive = false
        
        //let _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
                UIView.animate(withDuration: 0.4, delay: 0.6, options: [], animations: {
                    self.findButton.alpha = 1
                    self.heartButton.alpha = 1
                    self.deleteButton.alpha = 1
                    self.shareButton.alpha = 1
                }) { _ in
                    self.findButton.isHidden = false
                    self.heartButton.isHidden = false
                    self.deleteButton.isHidden = false
                    self.shareButton.isHidden = false
                }
            }
        default:
//            print("default")
            
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                    self.findButton.alpha = 0
                    self.heartButton.alpha = 0
                    self.deleteButton.alpha = 0
                    self.shareButton.alpha = 0
                }) { _ in
                    self.findButton.isHidden = true
                    self.heartButton.isHidden = true
                    self.deleteButton.isHidden = true
                    self.shareButton.isHidden = true
                }
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
            
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.view.backgroundColor = .black
                            self.xButtonView.alpha = 0
            }, completion: { completed in
                self.xButtonView.isHidden = true
            })
            
        } else {
            self.xButtonView.isHidden = false
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.xButtonView.alpha = 1
                            if #available(iOS 13.0, *) {
                                self.view.backgroundColor = .systemBackground
                            } else {
                                self.view.backgroundColor = .white
                            }
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
        //vc.image = self.photos[currentIndex - 1]
        vc.imageSize = photoSize
//        vc.url = self.photoPaths[currentIndex - 1]
        
        let filePath = self.photoModels[self.currentIndex - 1].filePath
        let urlString = URL(string: "\(folderURL)\(filePath)")
        vc.url = urlString
        
        
        vc.index = currentIndex - 1
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.photoModels.count - 1) {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.delegate = self
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        //vc.image = self.photos[currentIndex + 1]
        vc.imageSize = photoSize
//        vc.url = self.photoPaths[currentIndex + 1]
        
        
        let filePath = self.photoModels[self.currentIndex + 1].filePath
        let urlString = URL(string: "\(folderURL)\(filePath)")
        vc.url = urlString
        
        
        vc.index = currentIndex + 1
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextVC = pendingViewControllers.first as? PhotoZoomViewController else {
            return
        }
        
        self.nextIndex = nextVC.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {
            previousViewControllers.forEach { vc in
                let zoomVC = vc as! PhotoZoomViewController
                zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
            }

            self.currentIndex = self.nextIndex!
            self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex, sectionDidUpdate: self.currentSection)
        }
        
        self.nextIndex = nil
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
