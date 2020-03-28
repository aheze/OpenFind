//
//  PhotoZoomViewController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoZoomViewControllerDelegate: class {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class PhotoZoomViewController: UIViewController {
    
    @IBOutlet weak var mainContentView: UIView!
    
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoZoomViewControllerDelegate?
    var oldFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    //var image: UIImage!
    var index: Int = 0
    var url: URL?
    var imageSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            print(imageSize)
        }
    }

    var highlights = [Component]()
    var matchToColors = [String: [CGColor]]()
    var highlightColor = "00aeef"
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "LoadingImagePng"))
        //navigationController?.navigationItem.largeTitleDisplayMode = .never
        self.scrollView.delegate = self
        if #available(iOS 11, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        //self.imageView.image = self.image
        print(imageSize)
        self.mainContentView.frame = CGRect(x: self.imageView.frame.origin.x, y: self.imageView.frame.origin.y, width: self.imageSize.width, height: self.imageSize.height)
        self.view.addGestureRecognizer(self.doubleTapGestureRecognizer)
        
//        print("HIGH: \(highlights)")
        print("Frame: \(mainContentView.frame)")
        
       scaleHighlights()
        
        
    }
    func scaleInHighlight(component: Component) {
        //print("scale")
        DispatchQueue.main.async {
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
            layer.cornerRadius = component.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
            
            var newFillColor = UIColor()
            if component.isSpecialType == "Shared List" {
                
                var newRect = layer.frame
                newRect.origin.x += 1.5
                newRect.origin.y += 1.5
//                newRect.size.width -= 3
//                newRect.size.height -= 3
                layer.frame.origin.x -= 1.5
                layer.frame.origin.y -= 1.5
                layer.frame.size.width += 3
                layer.frame.size.height += 3
                newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: component.height / 4.5).cgPath
                
                let gradient = CAGradientLayer()
                gradient.frame = layer.bounds
//                gradient.colors = [#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor, #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor]
                if let gradientColors = self.matchToColors[component.text] {
                    
//                    print("gra colors \(gradientColors)")
                    gradient.colors = gradientColors
                    if let firstColor = gradientColors.first {
                        print("sdfsdf")
                        layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
                    }
                    
                }
                gradient.startPoint = CGPoint(x: 0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1, y: 0.5)
                
                gradient.mask = newLayer
                newLayer.fillColor = UIColor.clear.cgColor
                newLayer.strokeColor = UIColor.black.cgColor
                
                layer.addSublayer(gradient)
//                layer.backgroundColor = g
            } else if component.isSpecialType == "Shared Text List" {
//                newLayer.lineWidth = 8
                var newRect = layer.frame
                newRect.origin.x += 1.5
                newRect.origin.y += 1.5
//                newRect.size.width -= 3
//                newRect.size.height -= 3
                layer.frame.origin.x -= 1.5
                layer.frame.origin.y -= 1.5
                layer.frame.size.width += 3
                layer.frame.size.height += 3
                newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: component.height / 4.5).cgPath
                
                let gradient = CAGradientLayer()
                gradient.frame = layer.bounds
//                gradient.colors = [#colorLiteral(red: 0.3411764706, green: 0.6235294118, blue: 0.168627451, alpha: 1).cgColor, UIColor(hexString: self.highlightColor).cgColor]
                
                if let gradientColors = self.matchToColors[component.text] {
//                    print("HAS GRA")
                    var newColors = gradientColors
                    let newColor = UIColor(hexString: self.highlightColor)
                    
                    newColors.append(newColor.cgColor)
                    gradient.colors = newColors
                    
                    if let firstColor = gradientColors.first {
                        print("sdfsdf")
                        layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
                    }
//                                    gradient.colors = [#colorLiteral(red: 0.3411764706, green: 0.6235294118, blue: 0.168627451, alpha: 1).cgColor, UIColor(hexString: self.highlightColor).cgColor]
//                    print("new gra colors \(newColors)")
                }
                
                gradient.startPoint = CGPoint(x: 0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1, y: 0.5)
                gradient.mask = newLayer
                newLayer.fillColor = UIColor.clear.cgColor
                newLayer.strokeColor = UIColor.black.cgColor
                layer.addSublayer(gradient)
                
            } else {
                newLayer.fillColor = UIColor(hexString: component.colors.first ?? "ffffff").withAlphaComponent(0.3).cgColor
                newLayer.strokeColor = UIColor(hexString: component.colors.first ?? "ffffff").cgColor
                layer.addSublayer(newLayer)
            }
            
            let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
//            self.view.insertSubview(newView, aboveSubview: self.mainContentView)
            self.mainContentView.addSubview(newView)
            
            newView.layer.addSublayer(layer)
            newView.clipsToBounds = false
          
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            
            //newView.layer.position = CGPoint(x: component.x, y: component.y)
            
            
            
            newLayer.position = CGPoint(x: x, y: y)
            component.baseView = newView
            component.changed = true
            
            self.layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
        }
    }
    
    func layerScaleAnimation(layer: CALayer, duration: CFTimeInterval, fromValue: CGFloat, toValue: CGFloat) {
        let timing = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")

        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = fromValue
        scaleAnimation.toValue = toValue
        layer.add(scaleAnimation, forKey: "scale")
        CATransaction.commit()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        scaleHighlights()
        updateZoomScaleForSize(view.bounds.size)
        updateConstraintsForSize(view.bounds.size)
        print("FRAME: \(mainContentView.frame)")
        
//        if oldFrame != mainContentView.frame {
//
//        }
//        oldFrame = mainContentView.frame
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateZoomScaleForSize(view.bounds.size)
        updateConstraintsForSize(view.bounds.size)
    }
    func scaleHighlights() {
        for comp in highlights {
                    
                    
            let newX = comp.x * mainContentView.frame.width
            let newWidth = comp.width * mainContentView.frame.width
            let newY = comp.y * mainContentView.frame.height
            let newHeight = comp.height * mainContentView.frame.height
            
    //            print(newX)
    //            print(newY)
    //            print(newWidth)
    //            print(newHeight)
            
            print("OLD: x: \(comp.x), y: \(comp.y), width: \(comp.width), height: \(comp.height)")
            print("x: \(newX), y: \(newY), width: \(newWidth), height: \(newHeight)")
            
            
    //            comp.x = newX
    //            comp.y = newY
    //            comp.width = newWidth
    //            comp.height = newHeight
            
            let compToScale = Component()
            compToScale.x = newX
            compToScale.y = newY
            compToScale.width = newWidth
            compToScale.height = newHeight
            compToScale.colors = comp.colors
            compToScale.isSpecialType = comp.isSpecialType
            
    //            comp.width *= imageSize.width
    //            comp.y *= imageSize.height
    //            comp.height *= imageSize.height
            scaleInHighlight(component: compToScale)

        }
    }
//    override func viewSafeAreaInsetsDidChange() {
//
//        //When this view's safeAreaInsets change, propagate this information
//        //to the previous ViewController so the collectionView contentInsets
//        //can be updated accordingly. This is necessary in order to properly
//        //calculate the frame position for the dismiss (swipe down) animation
//
//        if #available(iOS 11, *) {
//
//            //Get the parent view controller (ViewController) from the navigation controller
//            guard let parentVC = self.navigationController?.viewControllers.first as? ViewController else {
//                return
//            }
//
//            //Update the ViewController's left and right local safeAreaInset variables
//            //with the safeAreaInsets for this current view. These will be used to
//            //update the contentInsets of the collectionView inside ViewController
//            parentVC.currentLeftSafeAreaInset = self.view.safeAreaInsets.left
//            parentVC.currentRightSafeAreaInset = self.view.safeAreaInsets.right
//
//        }
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        let pointInView = gestureRecognizer.location(in: self.mainContentView)
        var newZoomScale = self.scrollView.maximumZoomScale
        
        if self.scrollView.zoomScale >= newZoomScale || abs(self.scrollView.zoomScale - newZoomScale) <= 0.01 {
            newZoomScale = self.scrollView.minimumZoomScale
        }
        
        let width = self.scrollView.bounds.width / newZoomScale
        let height = self.scrollView.bounds.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
        self.scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    fileprivate func updateZoomScaleForSize(_ size: CGSize) {
        
        let widthScale = size.width / mainContentView.bounds.width
        let heightScale = size.height / mainContentView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - mainContentView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - mainContentView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        let contentHeight = yOffset * 2 + self.mainContentView.frame.height
        view.layoutIfNeeded()
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: contentHeight)
    }
}

extension PhotoZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainContentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(self.view.bounds.size)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.photoZoomViewController(self, scrollViewDidScroll: scrollView)
    }
}
