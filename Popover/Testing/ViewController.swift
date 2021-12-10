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
    
    //    lazy var popoverController: PopoverController = {
    //
    //        let window = UIApplication.shared
    //        .connectedScenes
    //        .filter { $0.activationState == .foregroundActive }
    //        .first
    //
    //        if let windowScene = SceneConstants.savedScene {
    //            let popoverController = PopoverController(
    //                popoverModel: popoverModel,
    //                windowScene: windowScene
    //            )
    //            return popoverController
    //        }
    //
    //        fatalError("NO scene")
    //    }()
    
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    
    var fields = [
        Field(text: .init(value: .string(""), colorIndex: 0)),
        Field(text: .init(value: .list(
            List(
                name: "List",
                desc: "Desc",
                contents: ["Word", "Branch", "Water", "Dirt"],
                iconImageName: "plus",
                iconColorName: 0x00aeef,
                dateCreated: Date()
            )
        ), colorIndex: 1)),
        Field(text: .init(value: .addNew(""), colorIndex: 2))
    ]
    
    //    var fieldSettingsModel = FieldSettingsModel()
    
    @IBAction func wordPressed(_ sender: Any) {
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.header = "WORD"
        fieldSettingsModel.defaultColor = self.fields[0].text.color
        fieldSettingsModel.selectedColor = self.fields[0].text.color
        fieldSettingsModel.alpha = self.fields[0].text.colorAlpha
        fieldSettingsModel.words = []
        fieldSettingsModel.showingWords = false
        fieldSettingsModel.editListPressed = nil
        
        let popoverView = FieldSettingsView(model: fieldSettingsModel)
//        var popover = Popover {
//            popoverView
//        }
        var popover = Popover(attributes: .init()) {
            popoverView
        } accessory: {
            PopoverReader { context in
                let _ = print("SIze: \(context.size)")
                Color.red.frame(width: context.size?.width, height: context.size?.width)
            }
            Color.black.opacity(0.2)
        }

        popover.position = .absolute(
            .init(
                originFrame: wordLabel.popoverOriginFrame(),
                originAnchor: .bottomLeft,
                popoverAnchor: .topLeft
            )
        )
        popover.attributes.presentation.animation = .spring()
        popover.attributes.presentation.transition = .opacity
        popover.attributes.dismissal.animation = .spring()
        popover.attributes.dismissal.transition = .opacity
        popover.attributes.dismissal.excludedFrames = {
            [
                self.purpleButton.windowFrame(),
                self.listButton.windowFrame(),
                self.listLabel.windowFrame(),
                self.tipButton.windowFrame()
            ]
        }
        popover.attributes.tag = "Field Popover"
        Popovers.present(popover)
    }
    
    @IBOutlet weak var listButton: UIButton!
    @IBAction func listPressed(_ sender: Any) {
        
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.header = "LIST"
        fieldSettingsModel.defaultColor = self.fields[1].text.color
        fieldSettingsModel.selectedColor = self.fields[1].text.color
        fieldSettingsModel.alpha = self.fields[1].text.colorAlpha
        fieldSettingsModel.words = ["Hello", "Other word", "Ice", "Water", "Context", "Popover", "Mud"]
        
        
        let popoverView = FieldSettingsView(model: fieldSettingsModel)
        var popover = Popover { popoverView }
        
        fieldSettingsModel.editListPressed = {
            Popovers.dismiss(popover)
        }
        
        popover.position = .absolute(
            .init(
                originFrame: listLabel.popoverOriginFrame(),
                originAnchor: .bottomLeft,
                popoverAnchor: .topLeft
            )
        )
        popover.attributes.presentation.animation = .spring()
        popover.attributes.presentation.transition = .opacity
        popover.attributes.dismissal.animation = .spring()
        popover.attributes.dismissal.transition = .opacity
        popover.attributes.dismissal.excludedFrames = {
            [
                self.purpleButton.windowFrame(),
                self.listButton.windowFrame(),
                self.listLabel.windowFrame()
            ]
        }
        popover.attributes.tag = "Field Popover"
        
        if let oldPopover = Popovers.popover(tagged: "Field Popover") {
            Popovers.replace(oldPopover, with: popover)
        } else {
            Popovers.present(popover)
        }
    }
    
    @IBOutlet weak var tipButton: UIButton!
    @IBAction func tipPressed(_ sender: Any) {
        if let wordPopover = Popovers.popover(tagged: "Field Popover") {
            var newPopover = wordPopover
            newPopover.position = .relative(
                .init(
                    containerFrame: { self.view.safeAreaLayoutGuide.layoutFrame },
                    popoverAnchor: .bottom
                )
            )
            
            Popovers.replace(wordPopover, with: newPopover)
        }
    }
    
    @IBOutlet weak var holdButton: UIButton!
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
        
    }
}


