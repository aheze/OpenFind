//
//  PopoverContainerViewController.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class PopoverContainerViewController: UIViewController {
    
    var popoverModel: PopoverModel
    
    init(popoverModel: PopoverModel) {
        self.popoverModel = popoverModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        print("loadView")
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        let popoverContainerView = PopoverContainerView(popoverModel: popoverModel)
        
        let hostingController = UIHostingController(rootView: popoverContainerView)
        
        self.addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
        
    }
}

/// https://stackoverflow.com/a/4010809/14351818
//class PassThroughView: UIView {
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        print("p: \(point)")
////        for keepPresentedRects in popovermodel
//
////        for subview in subviews {
////            let pointIsInsideSubview = subview.point(inside: convert(point, to: subview), with: event)
////
////            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
////                return true
////            }
////        }
//        return false
//    }
//}
