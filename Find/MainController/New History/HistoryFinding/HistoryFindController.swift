//
//  HistoryFindController.swift
//  Find
//
//  Created by Zheng on 3/8/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol ReturnCache: class {
    func returnHistCache(cachedImages: HistoryModel)
}
class HistoryFindController: UIViewController, UISearchBarDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBAction func helpButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    
    var photos = [HistoryModel]()

    weak var returnCache: ReturnCache?
//    func changeSearchPhotos(photos: [URL]) {
//        photos = photos
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        let customView = FindBar()
        SwiftEntryKit.display(entry: customView, using: attributes)
        
        helpButton.layer.cornerRadius = 6
        doneButton.layer.cornerRadius = 6
        
//        searchBar.delegate = self
//        searchBar.showsCancelButton = false
//        searchBar.searchTextField.placeholder = "Type here to find"
//        NotificationCenter.default.addObserver(self,
//        selector: #selector(self.keyboardNotification(notification:)),
//        name: UIResponder.keyboardWillChangeFrameNotification,
//        object: nil)
//        let textField = searchBar.searchTextField
//        let background = textField.subviews.first
//        let newHec = background?.backgroundColor?.toHexString()
//        print(newHec)
//        
//        let backgroundView = textField.subviews.first
////        textField.backgroundColor = UIColor.red
////        if #available(iOS 11.0, *) { // If `searchController` is in `navigationItem`
//            backgroundView?.backgroundColor = UIColor.red //Or any transparent color that matches with the `navigationBar color`
//            backgroundView?.subviews.forEach({ $0.removeFromSuperview() }) // Fixes an UI bug when searchBar appears or hides when scrolling
////        }
//        backgroundView?.layer.cornerRadius = 10.5
//        backgroundView?.layer.masksToBounds = true
//        
//        textField.backgroundColor = UIColor(named: "Gray4")
        
//        searchBar.backgroundColor = UIColor.red
        
    }
    
//    @objc func keyboardNotification(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//            let endFrameY = endFrame?.origin.y ?? 0
//            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
//            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
//            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
////            if endFrameY >= UIScreen.main.bounds.size.height {
////                self.bottomC.constant = 0.0
////            } else {
////                self.bottomC.constant = endFrame?.size.height ?? 0.0
////            }
//            UIView.animate(withDuration: duration,
//                                       delay: TimeInterval(0),
//                                       options: animationCurve,
//                                       animations: { self.view.layoutIfNeeded() },
//                                       completion: nil)
//        }
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
}
extension HistoryFindController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        
        return cell
//        dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
    }
    
    
    
    
}

//extension UIColor {
//       func toHexString() -> String {
//           var r:CGFloat = 0
//           var g:CGFloat = 0
//           var b:CGFloat = 0
//           var a:CGFloat = 0
//
//           getRed(&r, green: &g, blue: &b, alpha: &a)
//
//           let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
//
//           return String(format:"#%06x", rgb)
//       }
//   }
