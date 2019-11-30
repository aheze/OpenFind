//
//  FullScreenViewController.swift
//  Find
//
//  Created by Andrew on 11/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    
//    func changeImage(image: UIImage) {
//        print("change")
//        imageToBeDisplayed = image
//    }
    
    
    var topButtonShouldBeThere: Bool = false
    
    ///the hide/show timse
    var counter = Double(0)
    var timer = Timer()
    var isPlaying = false
    var limit: Double = 0
    
    var imageToBeDisplayed = UIImage() {
        didSet {
            imageView.image = imageToBeDisplayed
            view.bringSubviewToFront(xButtonView)
        }
    }
    
    @IBOutlet weak var xButtonView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            view.bringSubviewToFront(xButtonView)
            if touch.view == imageView {
                timer.invalidate()
                fadeButtons()
            } else if touch.view == view {
                timer.invalidate()
                fadeButtons()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = imageToBeDisplayed
        imageView.isUserInteractionEnabled = true
        setUpGestures()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleXPress(_:)))
        xButtonView.addGestureRecognizer(tap)
        xButtonView.isUserInteractionEnabled = true
        view.bringSubviewToFront(xButtonView)
        
        limit = Double(3)
        startTimer()
    }
    
    
    @objc func handleXPress(_ sender: UITapGestureRecognizer? = nil) {
        timer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    func setUpGestures() {
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.rotateGesture))
        pinchGesture.delegate = self
        panGesture.delegate = self
        rotateGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
        imageView.addGestureRecognizer(rotateGesture)
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func pinchGesture(recognizer:UIPinchGestureRecognizer) {        recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
        recognizer.scale = 1.0
    }
    @objc func panGesture(recognizer:UIPanGestureRecognizer) {        let gview = recognizer.view
    if recognizer.state == .began || recognizer.state == .changed {
         let translation = recognizer.translation(in: gview?.superview)
         gview?.center = CGPoint(x: (gview?.center.x)! + translation.x, y: (gview?.center.y)! + translation.y)
         recognizer.setTranslation(CGPoint.zero, in: gview?.superview)
    }
    }
    @objc func rotateGesture(recognizer:UIRotationGestureRecognizer) {       if recognizer.state == .began || recognizer.state == .changed {
        recognizer.view?.transform = (recognizer.view?.transform.rotated(by: recognizer.rotation))!
        recognizer.rotation = 0.0
    }
    }
    
    func startTimer() {
        xButtonView.isHidden = false
        ///after the animation, the buttons should be prepared to fade IN. But now, no.
        topButtonShouldBeThere = false
        xButtonView.alpha = 1
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    }
    @objc func UpdateTimer() {
        counter = counter + Double(0.1)
        if counter >= limit {
            timer.invalidate()
            counter = Double(0)
            buttonFadeOut()
        }
        
    }
    func buttonFadeOut() {
        xButtonView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.xButtonView.alpha = 0
        }, completion: { _ in
            self.xButtonView.isHidden = true
            self.topButtonShouldBeThere = true
            /// so when press, it will fade IN.
        })
    }
    func fadeButtons() {
        if topButtonShouldBeThere == false {
            ///fade the buttons out
            UIView.animate(withDuration: 0.2, animations: {
                self.xButtonView.alpha = 0
            }, completion: { _ in
                self.xButtonView.isHidden = true
                self.topButtonShouldBeThere = true
            })
        } else {
            ///show the buttons
            topButtonShouldBeThere = false
            self.xButtonView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.xButtonView.alpha = 1
            })
        }
        
    }
}
