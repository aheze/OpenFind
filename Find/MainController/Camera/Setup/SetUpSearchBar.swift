//
//  SetUpRamReel.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
import SnapKit
import VideoToolbox

/// Ramreel setup
extension ViewController: UICollectionViewDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    func setUpSearchBar() {
        
//        searchContentView.addSubview(listsView)
//        listsView.snp.makeConstraints { (make) in
//            //make.top.equalToSuperview()
//            //make.bottom.equalToSuperview()
//            make.height.equalTo(60)
//
//            make.width.equalTo(0)
//            make.top.equalToSuperview()
//            make.left.equalToSuperview()
//
//        }
//
//        searchContentView.addSubview(searchTextField)
//        searchTextField.snp.makeConstraints { (make) in
//            //make.bottom.equalToSuperview()
//            make.right.equalToSuperview()
//            make.height.equalTo(60)
//
//
//            make.top.equalToSuperview()
//            make.left.equalToSuperview()
//
//        }
        textLabel.alpha = 0
        listsLabel.alpha = 0
        tapToRemoveLabel.alpha = 0
        
        searchContentView.layer.cornerRadius = 12
        searchContentView.clipsToBounds = true
        
        newSearchTextField.layer.cornerRadius = 8
        
        newSearchTextField.inputAccessoryView = toolBar
        newSearchTextField.attributedPlaceholder = NSAttributedString(string: "Type here to find...",
                                                                   attributes:
                                                                   [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8784313725, green: 0.878935039, blue: 0.878935039, alpha: 0.75)])
       // newSearchTextField.
        
      //  let color: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //searchTextField.textContainer.maximumNumberOfLines = 1
//        dataSource = SimplePrefixQueryDataSource(data)
//        var frameRect = view.bounds
//        frameRect.size.height = 100
//        ramReel = RAMReel(frame: frameRect, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: false) {
//            print("Plain:", $0)
//            self.finalTextToFind = $0
//        }
//        ramReel.textField.inputAccessoryView = toolBar
        cancelButtonNew.layer.cornerRadius = 4
        autoCompleteButton.layer.cornerRadius = 4
        newMatchButton.layer.cornerRadius = 4
//
//        let arr = ["asdsad", "asdasd"]
//        arr.re
//
//        view.addSubview(ramReel.view)
//        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        ramReel.textFieldDelegate = self as UITextFieldDelegate
//        ramReel.textField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)),
//        for: UIControl.Event.editingChanged)
        
        
    }
    
    func updateHeight(expanding: Bool) {
        
        
        
    }
    func updateListsLayout(toType: String) {
        
        switch toType {
        case "onlyTextBox":
            print("onlyText")
            searchShrunk = false
            searchCollectionView.reloadData()
//            darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
//            NotificationCenter.default.post(name: .changeSearchListSize, object: nil, userInfo: [0: false])
            searchTextLeftC.constant = 8
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.newSearchTextField.backgroundColor = UIColor(named: "OpaqueBlur")
//                self.darkBlurEffect.alpha = 0.2
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        case "addListsNow":
            print("pressed a list so now text and lists")
            if searchShrunk == true {
                searchShrunk = false
                searchCollectionView.reloadData()
            }
//            NotificationCenter.default.post(name: .changeSearchListSize, object: nil, userInfo: [0: false])
            
            searchTextLeftC.constant = 8
            searchTextTopC.constant = 180
            searchCollectionTopC.constant = 60
            searchContentViewHeight.constant = 243
            
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.searchCollectionView.alpha = 1
                self.textLabel.alpha = 1
                self.listsLabel.alpha = 1
                self.tapToRemoveLabel.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            
        case "removeListsNow":
            print("removed every list so now ONLY TEXT")
            searchTextTopC.constant = 8
            searchCollectionTopC.constant = 8
            searchContentViewHeight.constant = 71
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.searchCollectionView.alpha = 0
                self.textLabel.alpha = 0
                self.listsLabel.alpha = 0
                self.tapToRemoveLabel.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        case "doneAndShrink":
            print("Done, shrinking lists")
            
            searchShrunk = true
//            darkBlurEffectHeightConstraint.constant = 100
//            for j in 0..<searchCollectionView.numberOfItems(inSection: 0) {
//                let indP = IndexPath(item: j, section: 0)
//                if let cell = searchCollectionView.cellForItem(at: indP) as! SearchCell {
//                    cell.labelRigh
//                }
////                collectionView.deselectItem(at: IndexPath(row: j, section: 0), animated: false)
//            }
            
//            var listOfInds = [IndexPath]()
//            for (index, cell) in selectedLists.enumerated() {
//                let indP = IndexPath(item: index, section: 0)
//                listOfInds.append(indP)
//            }
//
//
            searchCollectionView.reloadData()
//            searchCollectionView.reloadItems(at: <#T##[IndexPath]#>)
            
//            NotificationCenter.default.post(name: .changeSearchListSize, object: nil, userInfo: [0: true])
            switch selectedLists.count {
            case 0:
                print("nothing")
            case 1:
                print("1")
                searchTextLeftC.constant = 71
//                for (index, singleIndex) in selectedLists.enumerated() {
//                    let indP = IndexPath(item: index, section: 0)
//                    let cell = searchCollectionView.cellForItem(at: indP)
//
//                }
                
            default:
                print("default")
            }
            
            searchContentViewHeight.constant = 71
            searchTextTopC.constant = 8
            searchCollectionTopC.constant = 8
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.newSearchTextField.backgroundColor = UIColor(named: "TransparentBlur")
//                self.darkBlurEffect.alpha = 1
                self.textLabel.alpha = 0
                self.listsLabel.alpha = 0
                self.tapToRemoveLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        default:
            print("other")
        }
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == searchCollectionView {
//            return CGSize(width: 125, height: 60)
//        }
//
//        return CGSize(width: 0, height: 0)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }
   
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if ramReel.wrapper.selectedItem == nil {
//
//        autoCompleteButton.isEnabled = false
//        autoCompleteButton.alpha = 0.5
//        } else {
//        autoCompleteButton.isEnabled = true
//        autoCompleteButton.alpha = 1
//        }
//    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectedLists.count == 0 {
            updateListsLayout(toType: "onlyTextBox")
        } else {
            updateListsLayout(toType: "addListsNow")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateListsLayout(toType: "doneAndShrink")
         
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finalTextToFind = newSearchTextField.text ?? ""
        view.endEditing(true)
        print("Text: \(textField.text)")
        return true
    }
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//        //print("Text: \(textField.text)")
//
//    }
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//        autoCompleteButton.isEnabled = false
////
////        ramReel.view.bounds = view.bounds
////        print("textfield")
////        print(ramReel.collectionView.frame)
////        ramReel.collectionView.isHidden = false
////        ramReel.collectionView.alpha = 0
//        darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
//
//        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
////            self.autoCompleteButton.alpha = 0.5
////            self.ramReel.collectionView.alpha = 1
//            self.darkBlurEffect.alpha = 0.2
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//
//    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        //guard let imageView = view.viewWithTag(13579) else { print("sdflkj"); return }
//
//         self.darkBlurEffectHeightConstraint.constant = 100
//
//
//        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
//            //imageView.alpha = 0
////            self.ramReel.collectionView.alpha = 0
////            var frameRect = self.view.bounds
////            frameRect.size.height = 100
////            self.ramReel.view.bounds = frameRect
//            self.darkBlurEffect.alpha = 0.7
//
////            switch self.scanModeToggle {
////            case .classic:
////        //        self.sceneView.session.run(self.sceneConfiguration) ///which is ARWorldTracking
////            case .fast:
////         //       self.sceneView.session.run(AROrientationTrackingConfiguration())
////                self.stopCoaching()
////            case .focused:
////                let config = ARImageTrackingConfiguration()
////                if let tag1 = self.view.viewWithTag(1) { tag1.alpha = 1 }
////                if let tag2 = self.view.viewWithTag(2) { tag2.alpha = 1 }
////                self.stopCoaching()
////                self.sceneView.session.run(config)
////            }
//            //self.stopProcessingImage = false
//            self.view.layoutIfNeeded()
//        }, completion: {_ in
//           // imageView.removeFromSuperview()
//            //self.view.bringSubviewToFront(self.matchesBig)
////            self.ramReel.collectionView.isHidden = true
//        }
//        )
////             print(ramReel.selectedItem)
////        if ramReel.selectedItem == "" {
////            ramReel.placeholder = "Type here to find!"
////        }
////        finalTextToFind = ramReel.selectedItem ?? ""
//
//    }
    
    func convertToUIImage(buffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let temporaryContext = CIContext(options: nil)
        if let temporaryImage = temporaryContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
        {
            //let capturedImage = UIImage(cgImage: temporaryImage)
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            print(bufferSize)
            //let deviceRatio = deviceSize.height / deviceSize.width
//            let newWidth = bufferSize.height * deviceRatio
//            let offset = (bufferSize.width - newWidth)
//            let rect = CGRect(x: offset, y: 0, width: newWidth, height: bufferSize.height)
//            let croppedCgImage = temporaryImage.cropping(to: rect)!
            let capturedImage = UIImage(cgImage: temporaryImage, scale: 1.0, orientation: .right)
            return capturedImage
        }
        return nil
    }

    
    
}
extension Notification.Name {
    static let changeSearchListSize = Notification.Name("changeSearchListSize")
}


//extension UIImage {
//    public convenience init?(pixelBuffer: CVPixelBuffer, sceneView: ARSCNView) {
//        var cgImage: CGImage?
//        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
//
//        guard var newCgImage = cgImage else {
//            return nil
//        }
//        let orient = UIApplication.shared.statusBarOrientation
//        let viewportSize = sceneView.bounds.size
//        if let transform = sceneView.session.currentFrame?.displayTransform(for: orient, viewportSize: viewportSize).inverted() {
//            var finalImage = CIImage(cvPixelBuffer: pixelBuffer).transformed(by: transform)
//            guard let buffer = sceneView.session.currentFrame?.capturedImage else { return }
//            let temporaryContext = CIContext(options: nil)
//            if let temporaryImage = temporaryContext.createCGImage(finalImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
//            {
//                newCgImage = temporaryImage
//            }
//        }
//        self.init(cgImage: newCgImage)
//    }
//}

