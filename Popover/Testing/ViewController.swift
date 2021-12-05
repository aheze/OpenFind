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
        Field(text: .init(value: .addNew(""), colorIndex: 1))
    ]
    
//    var fieldSettingsModel = FieldSettingsModel()
    
    @IBAction func wordPressed(_ sender: Any) {
        print("Word pressed")
//        let popover = Popover(context: <#T##PopoverContext#>, view: FieldSettingsView(configuration: <#T##Binding<PopoverConfiguration.FieldSettings>#>, stopDraggingGesture: <#T##Binding<Bool>#>))
//        let configuration = PopoverConfiguration.FieldSettings(
//            popoverContext: .init(
//                position: self.wordLabel.popoverOrigin(anchor: .bottomLeft),
//                keepPresentedRects: [
//                    self.purpleButton.windowFrame(),
//                    self.listButton.windowFrame(),
//                    self.listLabel.windowFrame()
//                ]
//            ),
//            defaultColor: self.fields[0].text.color,
//            selectedColor: self.fields[0].text.color,
//            alpha: self.fields[0].text.colorAlpha,
//            propertiesChanged:  { [weak self] newConfiguration in
//                guard let self = self else { return }
//                self.fields[0].text.color = newConfiguration.selectedColor
//                self.fields[0].text.colorAlpha = newConfiguration.alpha
//
//            })
//        let popover = Popover.fieldSettings(configuration)
//        withAnimation {
//            popoverModel.popovers.append(popover)
//        }
        
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.configuration = PopoverConfiguration.FieldSettings(
            header: "WORDS",
            defaultColor: self.fields[0].text.color,
            selectedColor: self.fields[0].text.color,
            alpha: self.fields[0].text.colorAlpha,
            words: [],
            showingWords: false,
            editListPressed: nil
        )
//        let configurationBinding = Binding { () -> PopoverConfiguration.FieldSettings in
////            print("get: \(configuration)")
//
//            return configuration
//        } set: { newValue in
////            print("new: \(newValue)")
//            return configuration = newValue
//        }
        
        let model = PopoverModel()
        let popoverView = AnyView(FieldSettingsView(model: fieldSettingsModel, stopDraggingGesture: model.draggingEnabled))
        let popover = Popover(view: popoverView)
        Popovers.model.popovers.append(popover)
    }
    
    
//    lazy var configuration = PopoverConfiguration.FieldSettings(
//        header: "WORDS",
//        defaultColor: self.fields[0].text.color,
//        selectedColor: self.fields[0].text.color,
//        alpha: self.fields[0].text.colorAlpha,
//        words: [],
//        showingWords: false,
//        editListPressed: nil
//    )
//    lazy var configurationBinding = Binding { () -> PopoverConfiguration.FieldSettings in
////            print("get: \(configuration)")
//        return self.configuration
//    } set: { newValue in
////            print("new: \(newValue)")
//        return self.configuration = newValue
//    }
    
    @IBOutlet weak var listButton: UIButton!
    @IBAction func listPressed(_ sender: Any) {
        
//        var configuration = PopoverConfiguration.FieldSettings(
//            popoverContext: .init(
//                position: self.listLabel.popoverOrigin(anchor: .bottomLeft),
//                keepPresentedRects: [
//                    self.purpleButton.windowFrame()
//                ]
//            ),
//            header: "LIST",
//            defaultColor: self.fields[0].text.color,
//            selectedColor: self.fields[0].text.color,
//            alpha: self.fields[0].text.colorAlpha,
//            words: ["Hello", "Other word"],
//            editListPressed: {
//                print("Edit")
//                if let existingFieldSettingsPopoverIndex = self.indexOfExistingFieldPopover() {
//                    withAnimation {
//                        self.popoverModel.popovers.remove(at: existingFieldSettingsPopoverIndex)
//                    }
//                }
//            }
//        ) { [weak self] newConfiguration in
//                guard let self = self else { return }
//                self.fields[0].text.color = newConfiguration.selectedColor
//                self.fields[0].text.colorAlpha = newConfiguration.alpha
//    
//        }
//        
//        
//        if let existingFieldSettingsPopoverIndex = indexOfExistingFieldPopover() {
//            withAnimation {
//                
//                /// use same ID for smooth position animation
//                configuration.popoverContext.id = popoverModel.popovers[existingFieldSettingsPopoverIndex].id
//                let popover = Popover.fieldSettings(configuration)
//                popoverModel.popovers[existingFieldSettingsPopoverIndex] = popover
//            }
//        } else {
//            withAnimation {
//                let popover = Popover.fieldSettings(configuration)
//                popoverModel.popovers.append(popover)
//            }
//        }
    }
    
//    func indexOfExistingFieldPopover() -> Int? {
//        return popoverModel.popovers.indices.first(where: { index in
//            if case .fieldSettings(_) = popoverModel.popovers[index] {
//                return true
//            } else {
//                return false
//            }
//        })
//    }
    
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
        
//        _ = popoverController
    }


}


