//
//  ViewController.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    var popoverModel = PopoverModel()
    lazy var popoverController: PopoverController = {
        
        let window = UIApplication.shared
        .connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first
        
        print("saved: \(SceneConstants.savedScene)")
        
        if let windowScene = SceneConstants.savedScene {
            let popoverController = PopoverController(
                popoverModel: popoverModel,
                windowScene: windowScene
            )
            return popoverController
        }
        
        fatalError("NO scnee")
//        return PopoverController(popoverModel: popoverModel, windowScene: view.window!.windowScene!)
    }()
    
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    
    var fields = [
        Field(text: .init(value: .string(""))),
        Field(text: .init(value: .addNew("")))
    ]
    @IBAction func wordPressed(_ sender: Any) {
        print("Wpr p[resed")
        
        let binding = Binding(
            get: {
                PopoverConfiguration.FieldSettings(
                    origin: self.wordLabel.frame.origin,
                    keepPresentedRects: [self.purpleButton.frame],
                    defaultColor: 0x00aeef,
                    selectedColor: self.fields[0].text.color,
                    alpha: 0.5
                )
            }, set: { fieldSettings in
                self.fields[0].text.color = fieldSettings.selectedColor
                self.fields[0].text.colorAlpha = fieldSettings.alpha
            }
        )
        
        let popover = Popover.fieldSettings(binding)
        popoverModel.popovers.append(popover)
    }
    
    @IBAction func listPressed(_ sender: Any) {
    }
    
    
    @IBAction func tipPressed(_ sender: Any) {
    }
    
    @IBAction func holdDown(_ sender: Any) {
    }
    
    @IBAction func holdUp(_ sender: Any) {
    }
    
    @IBOutlet weak var purpleButton: UIButton!
    @IBAction func purpleButtonPressed(_ sender: Any) {
        print("purple pressed")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("widnow \(view.window?.windowScene)")
        
        _ = popoverController
    }


}

