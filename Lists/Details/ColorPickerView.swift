//
//  ColorPickerView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class ColorPickerViewModel: ObservableObject {
    @Published var color = UIColor.blue
}

class ColorPickerViewController: UIViewController {
    
    var model: ColorPickerViewModel
    init(model: ColorPickerViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        let containerView = ColorPickerView(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        view.isUserInteractionEnabled = false
    }
}

struct ColorPickerView: View {
    @ObservedObject var model: ColorPickerViewModel
    
    var body: some View {
        Circle()
            .fill(Color(model.color))
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(8)
    }
}
