//
//  FullScreenViewController.swift
//  Find
//
//  Created by Andrew on 11/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    var shouldShowTopButtons: Bool = false
    
    ///the hide/show timse
    var counter = Double(0)
    var timer = Timer()
    var isPlaying = false
    var limit: Double = 0
    
    @IBOutlet weak var xButtonView: UIImageView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == view {
                limit = Double(5)
                startTimer()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleXPress(_:)))
        xButtonView.addGestureRecognizer(tap)
        xButtonView.isUserInteractionEnabled = true
        limit = Double(3)
        startTimer()
    }
    
    
    
    @objc func handleXPress(_ sender: UITapGestureRecognizer? = nil) {
        timer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    func startTimer() {
        showButtons()
        shouldShowTopButtons = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)

    }
    @objc func UpdateTimer() {
        counter = counter + Double(0.1)
        if counter >= limit {
            shouldShowTopButtons = false
            timer.invalidate()
            counter = Double(0)
            fadeButtons()
        }
        
    }
    func showButtons() {
        self.xButtonView.isHidden = false
        self.shouldShowTopButtons = true
        UIView.animate(withDuration: 0.5, animations: {
            self.xButtonView.alpha = 1
        })
        
    }
    func fadeButtons() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.xButtonView.alpha = 0
        }, completion: { _ in
            self.shouldShowTopButtons = false
            self.xButtonView.isHidden = true
            
        })
        
    }
}
