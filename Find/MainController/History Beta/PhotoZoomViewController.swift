//
//  PhotoZoomViewController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit
import SDWebImage
import Vision

protocol PhotoZoomViewControllerDelegate: class {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

protocol ReturnHowManyMatches: class {
    func howMany(number: Int, searchInCache: Bool)
}

class PhotoZoomViewController: UIViewController {
    
    @IBOutlet weak var mainContentView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!

    
    @IBOutlet weak var progressHeightC: NSLayoutConstraint!
    
    var cameFromFind = false
    var ocrSearching = false
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    var deviceSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var drawingView: UIView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoZoomViewControllerDelegate?
    weak var returnNumber: ReturnHowManyMatches?
    
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
//    var highlightColor = "00aeef"
    
    var photoComp = EditableHistoryModel()
    
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.alpha = 0
        self.imageView.sd_setImage(with: url)
        self.scrollView.delegate = self
        if #available(iOS 11, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        print(imageSize)
        mainContentView.frame = CGRect(x: self.imageView.frame.origin.x, y: self.imageView.frame.origin.y, width: self.imageSize.width, height: self.imageSize.height)
        
        oldFrame = mainContentView.frame
//        print("OLDF::: \(oldFrame)")
        view.addGestureRecognizer(self.doubleTapGestureRecognizer)
//        scaleHighlights()
//        print("HIGHS: \(highlights)")
        
        if cameFromFind {
            DispatchQueue.main.async {
                self.scaleHighlights()
            }
        }
//        fastFind()
    }
    func scaleInHighlight(component: Component, unsure: Bool = false) {
        guard let colors = matchToColors[component.text] else { print("NO COLORS! scalee"); return }
//        print("COLROS zoom text: \(component.text).. \(colors)")
        DispatchQueue.main.async {
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
            layer.cornerRadius = component.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
            
//            var newFillColor = UIColor()
            if colors.count > 1 {
                var newRect = layer.frame
                newRect.origin.x += 1.5
                newRect.origin.y += 1.5
                layer.frame.origin.x -= 1.5
                layer.frame.origin.y -= 1.5
                layer.frame.size.width += 3
                layer.frame.size.height += 3
                newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: component.height / 4.5).cgPath
                let gradient = CAGradientLayer()
                gradient.frame = layer.bounds
                if let gradientColors = self.matchToColors[component.text] {
                    gradient.colors = gradientColors
                    if let firstColor = gradientColors.first {
                        layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
                    }
                    
                }
                gradient.startPoint = CGPoint(x: 0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1, y: 0.5)
                
                gradient.mask = newLayer
                newLayer.fillColor = UIColor.clear.cgColor
                newLayer.strokeColor = UIColor.black.cgColor
                
                layer.addSublayer(gradient)
            } else {
                if let firstColor = colors.first {
                    newLayer.fillColor = firstColor.copy(alpha: 0.3)
                    newLayer.strokeColor = firstColor
                    layer.addSublayer(newLayer)
                }
            }
            
            let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
            self.drawingView.addSubview(newView)
            
            newView.layer.addSublayer(layer)
            newView.clipsToBounds = false
          
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            
            if unsure {
                newView.alpha = 0.4
            }
            newLayer.position = CGPoint(x: x, y: y)
            component.baseView = newView
            component.changed = true
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
        updateZoomScaleForSize(view.bounds.size)
        updateConstraintsForSize(view.bounds.size)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateZoomScaleForSize(view.bounds.size)
        updateConstraintsForSize(view.bounds.size)
    }
    func scaleHighlights() {
        
        drawingView.subviews.forEach({ $0.removeFromSuperview() })
        for comp in highlights {
            let newX = comp.x * oldFrame.size.width
            let newWidth = comp.width * oldFrame.size.width
            let newY = comp.y * oldFrame.size.height
            let newHeight = comp.height * oldFrame.size.height
//            print("x: \(newX), y: \(newY), width: \(newWidth), height: \(newHeight)")
            
            let compToScale = Component()
            compToScale.x = newX - 6
            compToScale.y = newY - 3
            compToScale.width = newWidth + 12
            compToScale.height = newHeight + 6
            compToScale.colors = comp.colors
            compToScale.text = comp.text
            compToScale.isSpecialType = comp.isSpecialType
            
            if newHeight <= 50 {
                scaleInHighlight(component: compToScale)
            } else {
                scaleInHighlight(component: compToScale, unsure: true)
            }

        }
    }
    
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

extension PhotoZoomViewController: ChangedSearchTermsFromZoom {
    
    

    
     func returnTerms(matchToColorsR: [String: [CGColor]]) {
//        getRead
//        if initializedView {
            print("RETURNED TERMS!!!")
            print("DATA: \(matchToColorsR)")
        matchToColors = matchToColorsR
        
        fastFind() 
        
    }
    func pressedReturn() {
        ocrFind(photo: photoComp)
    }
    
    func fastFind() {
        DispatchQueue.global(qos: .background).async {
            let photo = self.photoComp
            var num = 0
            var newFastComponents = [Component]()
            ///Cycle through each block of text. Each cont may be a line long.
            for cont in photo.contents {
                let lowercaseContText = cont.text.lowercased()
                let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
                for match in self.matchToColors.keys {
                    if lowercaseContText.contains(match) {
                        let finalW = individualCharacterWidth * CGFloat(match.count)
                        let indicies = lowercaseContText.indicesOf(string: match)
                        
                        for index in indicies {
                            num += 1
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let finalX = CGFloat(cont.x) + addedWidth
                            let newComponent = Component()
                            
                            newComponent.x = finalX
                            newComponent.y = CGFloat(cont.y) - (CGFloat(cont.height))
                            newComponent.width = finalW
                            newComponent.height = CGFloat(cont.height)
                            newComponent.text = match
                            
                            newFastComponents.append(newComponent)
                        }
                    }
                }
            }
            
            self.returnNumber?.howMany(number: newFastComponents.count, searchInCache: true)
            print("HOW MANY: \(newFastComponents.count)")
            
            self.highlights = newFastComponents
            DispatchQueue.main.async {
                self.scaleHighlights()
            }
            
        }
        
    }
    
    func ocrFind(photo: EditableHistoryModel) {
        ocrSearching = true
        
        DispatchQueue.main.async {
            self.progressHeightC.constant = 20
            UIView.animate(withDuration: 0.12, animations: {
                self.progressView.alpha = 1
                self.progressView.setProgress(Float(0), animated: true)
                self.view.layoutIfNeeded()
//                self.progressView.transform = CGAffineTransform(scaleX: 1, y: <#T##CGFloat#>)
            })
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let photoUrl = URL(string: "\(self.folderURL)\(photo.filePath)") else { print("WRONG URL!!!!"); return }
            
            let request = VNRecognizeTextRequest { request, error in
                self.handleFastDetectedText(request: request, error: error, photo: photo)
            }
            
            var customFindArray = [String]()
            for findWord in self.matchToColors.keys {
                customFindArray.append(findWord)
                customFindArray.append(findWord.lowercased())
                customFindArray.append(findWord.uppercased())
                customFindArray.append(findWord.capitalizingFirstLetter())
            }
            
            request.customWords = customFindArray
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en_GB"]
            let imageRequestHandler = VNImageRequestHandler(url: photoUrl, orientation: .up)
            do {
                try imageRequestHandler.perform([request])
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    func handleFastDetectedText(request: VNRequest?, error: Error?, photo: EditableHistoryModel) {
            
        DispatchQueue.main.async {
            self.progressHeightC.constant = 2
            UIView.animate(withDuration: 0.6, animations: {
                self.progressView.setProgress(Float(1), animated: true)
                self.progressView.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
        
       
        guard let results = request?.results, results.count > 0 else {
            print("no results")
//                alreadyCachedPhotos.append(newCachedPhoto)
//            dispatchSemaphore.signal()
//            dispatchGroup.leave()
//
            self.returnNumber?.howMany(number: -1, searchInCache: false)
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
        var numberOfMatches = 0
        
        var findComponents = [Component]()
        
        for cont in contents {
            let lowercaseContText = cont.text.lowercased()
            
            let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
            for match in self.matchToColors.keys {
                if lowercaseContText.contains(match) {
                    let finalW = individualCharacterWidth * CGFloat(match.count)
                    let indicies = lowercaseContText.indicesOf(string: match)
                    
                    for index in indicies {
                        numberOfMatches += 1
                        let addedWidth = individualCharacterWidth * CGFloat(index)
                        let finalX = CGFloat(cont.x) + addedWidth
                        
                        let newComponent = Component()
                        
                        newComponent.x = finalX
                        newComponent.y = CGFloat(cont.y) - (CGFloat(cont.height))
                        newComponent.width = finalW
                        newComponent.height = CGFloat(cont.height)
                        newComponent.text = match
                        
                        findComponents.append(newComponent)
                        
                    }
                }
            }
        }
        
        var componentsToAdd = [Component]()
//        var newMatchesNumber = 0
        
        for newFindMatch in findComponents {
            var smallestDist = CGFloat(999)
            for findMatch in highlights {
                
                let point1 = CGPoint(x: findMatch.x, y: findMatch.y)
                let point2 = CGPoint(x: newFindMatch.x, y: newFindMatch.y)
                let pointDistance = relativeDistance(point1, point2)
                
//                                print("OLD: \(point1), new: \(point2)")
                if pointDistance < smallestDist {
                    smallestDist = pointDistance
                }
                
            }
//                            print("SMALL DIST: \(smallestDist)")
            if smallestDist >= 0.008 { ///Bigger, so add it
                componentsToAdd.append(newFindMatch)
//                newMatchesNumber += 1
            }
            
        }
        highlights += componentsToAdd
        self.returnNumber?.howMany(number: highlights.count, searchInCache: false)
//        scaleHighlights()
        DispatchQueue.main.async {
            self.scaleHighlights()
        }
//        existingModel.components += componentsToAdd
//        existingModel.numberOfMatches += newMatchesNumber
//        print("ADD MATCHES: \(newMatchesNumber)")
        
//            newMod.components = findComponents
            
//            resultPhotos.append(newMod)
             
        
    }
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
