//
//  SettingsViewController.swift
//  Find
//
//  Created by Andrew on 11/3/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController {
    
    
    
    @IBOutlet weak var blackXButtonView: UIImageView!
    
    @IBOutlet weak var highlightColorView: UIView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var tealButton: UIButton!
    @IBOutlet weak var lightblueButton: UIButton!
    @IBOutlet weak var findblueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    

    @IBOutlet weak var watchTutorialView: UIView!
    
    @IBOutlet weak var clearHistoryView: UIView!
    
    @IBOutlet weak var resetSettingsView: UIView!
    
    @IBOutlet weak var rateAppView: UIView!
    
    @IBOutlet weak var helpView: UIView!
    
    
    
    
    
    
    
    
    //    @IBOutlet weak var prefilterView: UIView!
//    @IBOutlet weak var prefilterSwitch: UISwitch!
    
    @IBOutlet weak var otherSettingsView: UIView!
    
    
    
    
    
    @IBOutlet weak var feedbackView: UIView!
    
    @IBOutlet weak var creditsView: UIView!
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    
    
    override func viewDidLoad() {
        setUpSettingsRoundedCorners()
        //setUpSettingsSwitches()
        setUpXButton()
        setUpGradientFeedback()
        addGestureRecognizers()
    }
    
    func setUpXButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackXPress(_:)))
        blackXButtonView.addGestureRecognizer(tap)
        blackXButtonView.isUserInteractionEnabled = true
    }
    @objc func handleBlackXPress(_ sender: UITapGestureRecognizer? = nil) {
       // presentationController?.delegate?.presentationControllerDidDismiss
        // delegate?.presentationControllerDidDismiss?(presentationController!)
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
