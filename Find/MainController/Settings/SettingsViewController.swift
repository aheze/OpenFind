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
    
    @IBOutlet weak var monthColorsView: UIView!
    @IBOutlet weak var janButton: UIButton!
    @IBOutlet weak var febButton: UIButton!
    @IBOutlet weak var marButton: UIButton!
    @IBOutlet weak var aprButton: UIButton!
    @IBOutlet weak var mayButton: UIButton!
    @IBOutlet weak var junButton: UIButton!
    @IBOutlet weak var julButton: UIButton!
    @IBOutlet weak var augButton: UIButton!
    @IBOutlet weak var sepButton: UIButton!
    @IBOutlet weak var octButton: UIButton!
    @IBOutlet weak var novButton: UIButton!
    @IBOutlet weak var decButton: UIButton!
    
    @IBOutlet weak var prefilterView: UIView!
    @IBOutlet weak var prefilterSwitch: UISwitch!
    
    @IBOutlet weak var otherSettingsView: UIView!
    @IBOutlet weak var statusHUDSwitch: UISwitch!
    
    
    
    @IBOutlet weak var creditsView: UIView!
    
    
    
    override func viewDidLoad() {
        setUpSettingsRoundedCorners()
        setUpSettingsSwitches()
        setUpXButton()
    }
    
    func setUpXButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackXPress(_:)))
        blackXButtonView.addGestureRecognizer(tap)
        blackXButtonView.isUserInteractionEnabled = true
    }
    @objc func handleBlackXPress(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
