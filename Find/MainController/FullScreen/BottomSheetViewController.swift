//
//  BottomSheetViewController.swift
//  Find
//
//  Created by Andrew on 11/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController, PulleyDrawerViewControllerDelegate {
    
    var isOpen: Bool = false
    
    @IBOutlet weak var arrowView: ArrowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrowView.update(to: .up, animated: true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        arrowView.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if isOpen == true {
            isOpen = false
            arrowView.update(to: .up, animated: true)
            pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        } else {
            isOpen = true
            arrowView.update(to: .down, animated: true)
            pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
        }
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if drawer.drawerPosition == .collapsed {
            arrowView.update(to: .up, animated: true)
            isOpen = false
        } else {
            arrowView.update(to: .down, animated: true)
            isOpen = true
        }
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 50.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 185.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.partiallyRevealed, .collapsed] // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
}
