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

class PhotoZoomViewController: UIViewController {
    
    @IBOutlet weak var mainContentView: UIView!
    
    var ocrSearching = false
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    var deviceSize = UIScreen.main.bounds.size
    
    
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
//    var currentMatchStrings = [String]()
    var matchToColors = [String: [CGColor]]()
    var highlightColor = "00aeef"
    
    var photoComp = EditableHistoryModel()
    
    
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
//        print("Frame: \(mainContentView.frame)")
//
//        print("MATCHS zoom: \(matchToColors)")
//        print("MATCH COLORS: \(matchToColors)")
       scaleHighlights()
        
        
    }
    func scaleInHighlight(component: Component) {
        
//        print("COMPONENT; \(component.text)")
        //print("scale")
        guard let colors = matchToColors[component.text] else { print("NO COLORS! scalee"); return }
        print("COLROS zoom text: \(component.text).. \(colors)")
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
                print("shared list")
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
//                        print("sdfsdf")
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
            } else {
                
//                print("Normal")
                
                if let firstColor = colors.first {
                    newLayer.fillColor = firstColor.copy(alpha: 0.3)
                    newLayer.strokeColor = firstColor
                    layer.addSublayer(newLayer)
                }
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
            
//            self.layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
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
            
//            print("OLD: x: \(comp.x), y: \(comp.y), width: \(comp.width), height: \(comp.height)")
//            print("x: \(newX), y: \(newY), width: \(newWidth), height: \(newHeight)")
            
            
    //            comp.x = newX
    //            comp.y = newY
    //            comp.width = newWidth
    //            comp.height = newHeight
            if newHeight <= 200 {
                let compToScale = Component()
                compToScale.x = newX - 6
                compToScale.y = newY - 3
                compToScale.width = newWidth + 12
                compToScale.height = newHeight + 6
                compToScale.colors = comp.colors
                compToScale.text = comp.text
                compToScale.isSpecialType = comp.isSpecialType
                scaleInHighlight(component: compToScale)
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

    
    func returnTerms(matchToColorsR: [String : [CGColor]]) {
        matchToColors = matchToColorsR
    }
    
    func fastFind() {
        
        DispatchQueue.global(qos: .background).async {
//            print("1")
            var findModels = [FindModel]()
    //        var heights = [CGFloat]()
            
    //        print(
            let photo = self.photoComp
            print("searching in photo")
            var num = 0
            
//            let newMod = FindModel()
            var newFastComponents = [Component]()
//            newMod.photo = photo
            
//            var compMatches = [String: [ArrayOfMatchesInComp]]() ///COMPONENT to ranges
            ///Cycle through each block of text. Each cont may be a line long.
            for cont in photo.contents {
//                var matchRanges = [ArrayOfMatchesInComp]()
                var hasMatch = false
                let lowercaseContText = cont.text.lowercased()
                let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
                for match in self.matchToColors.keys {
                    if lowercaseContText.contains(match) {
                        hasMatch = true
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
//
//                            let newRangeObject = ArrayOfMatchesInComp()
//                            newRangeObject.descriptionRange = index...index + match.count
//                            newRangeObject.text = match
//                            matchRanges.append(newRangeObject)
                        }
                    }
                }
          
                
            }
            
            self.highlights = newFastComponents
//            newMod.numberOfMatches = num
            
            DispatchQueue.main.async {
                self.scaleHighlights()
//                photoComp = newMod
                
           
            }
            
        }
        
    }
    
    func ocrFind(photo: EditableHistoryModel) {
        ocrSearching = true
        
//        DispatchQueue.main.async {
//            self.activityIndicator.startAnimating()
//            self.histCenterC.constant = 13
//            UIView.animate(withDuration: 0.12, animations: {
//                self.view.layoutIfNeeded()
//                self.progressView.alpha = 1
//                self.progressView.setProgress(Float(0), animated: true)
//            })
//        }
        
        DispatchQueue.global(qos: .background).async {
//            self.ocrPassCount = 0
//            var number = 0
            
        
                    
    //                number += 1
    //                    print("num: \(number)")
    //                    let indP = IndexPath(item: number - 1, section: 0)
                    
//                    self.dispatchGroup.enter()
                    
                    
                    
    //                print("OCR: \(self.ocrPassCount)")
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
                    
    //                request.progressHandler = { (request, value, error) in
    ////                    print("Progress: \(value)")
    //                }
                    do {
                        try imageRequestHandler.perform([request])
                    } catch let error {
                        print("Error: \(error)")
                    }
                    
                
               
            
        }
//        dispatchGroup.notify(queue: dispatchQueue) {
//            if self.statusOk == true {
//                self.ocrSearching = false
//    //            self.
//                DispatchQueue.main.async {
//                    self.showWarning(show: false)
//                    self.tableView.reloadData()
//                    self.helpButton.isEnabled = true
//                }
//
//                self.changeFindbar?.change(type: "Enable")
//                print("Finished all requests.")
//                self.finishOCR()
//            }
//        }
        
    }
    
    func handleFastDetectedText(request: VNRequest?, error: Error?, photo: EditableHistoryModel) {
            
        
//        self.ocrPassCount += 1
//        DispatchQueue.main.async {
////            print("HPOSO COUNT: \(self.photos.count)")
//            let individualProgress = CGFloat(self.ocrPassCount) / CGFloat(self.photos.count)
////            print("IND PROGR: \(individualProgress)")
//            UIView.animate(withDuration: 0.6, animations: {
//                self.progressView.setProgress(Float(individualProgress), animated: true)
//            })
//        }
        
       
        guard let results = request?.results, results.count > 0 else {
            print("no results")
//                alreadyCachedPhotos.append(newCachedPhoto)
//            dispatchSemaphore.signal()
//            dispatchGroup.leave()
//
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
        
        let newMod = FindModel()
        
        var compMatches = [String: [ArrayOfMatchesInComp]]()
        var numberOfMatches = 0
        
        var findComponents = [Component]()
        for cont in contents {
            var matchRanges = [ArrayOfMatchesInComp]()
            var hasMatch = false
            
            let lowercaseContText = cont.text.lowercased()
            
            let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
            for match in self.matchToColors.keys {
                if lowercaseContText.contains(match) {
//                    print("MATCH!! \(match), in: \(cont.text)")
                    hasMatch = true
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
                        
                        let newRangeObject = ArrayOfMatchesInComp()
                        newRangeObject.descriptionRange = index...index + match.count
                        newRangeObject.text = match
                        matchRanges.append(newRangeObject)
                        
                    }
                    
                    
                    
                }
            }
                
            if hasMatch == true {
                compMatches[cont.text] = matchRanges
            }
        }
        var descriptionOfPhoto = ""
        var finalRangesObjects = [ArrayOfMatchesInComp]()
        
        if numberOfMatches >= 1 {
            var existingCount = 0
            for (index, comp) in compMatches.enumerated() {
                if index <= 2 {
                    let thisCompString = comp.key
                    
                    if descriptionOfPhoto == "" {
                        existingCount += 3
                        descriptionOfPhoto.append("...\(thisCompString)...")
                    } else {
                        existingCount += 4
                        descriptionOfPhoto.append("\n...\(thisCompString)...")
                    }
                    for compRange in comp.value {
                        let newStart = existingCount + (compRange.descriptionRange.first ?? 0)
                        let newEnd = existingCount + (compRange.descriptionRange.last ?? 1)
                        let newRange = newStart...newEnd
                        
                        let matchObject = ArrayOfMatchesInComp()
                        matchObject.descriptionRange = newRange
                        matchObject.text = compRange.text
                        
                        finalRangesObjects.append(matchObject)
                    }
                    let addedLength = 3 + thisCompString.count
                    existingCount += addedLength
                }
            }
            
            let totalWidth = self.deviceSize.width
            let finalWidth = totalWidth - 146
            let height = descriptionOfPhoto.heightWithConstrainedWidth(width: finalWidth, font: UIFont.systemFont(ofSize: 14))
            let finalHeight = height + 70
            
            newMod.photo = photo
            newMod.descriptionMatchRanges = finalRangesObjects
            newMod.numberOfMatches = numberOfMatches
            newMod.descriptionText = descriptionOfPhoto
            newMod.descriptionHeight = finalHeight
            
            newMod.components = findComponents
            
//            resultPhotos.append(newMod)
             
        }
    }
}
