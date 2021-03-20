//
//  PermissionsVC+Views.swift
//  FindAppClip1
//
//  Created by Zheng on 3/15/21.
//

import SwiftUI

extension PermissionsViewController {
    func setupViews() {
        searchBarView.layer.cornerRadius = 16
        
        permissionsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        permissionsView.layer.cornerRadius = 32
        permissionsShadowView.layer.cornerRadius = 32
        permissionsBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        permissionsBackgroundView.layer.cornerRadius = 32
        
        searchBarView.layer.shadowColor = UIColor.black.cgColor
        searchBarView.layer.shadowOpacity = 0.3
        searchBarView.layer.shadowOffset = CGSize(width: 0, height: 4)
        searchBarView.layer.shadowRadius = 8
        searchBarView.layer.shouldRasterize = true
        searchBarView.layer.rasterizationScale = UIScreen.main.scale
        
        permissionsShadowView.layer.shadowColor = UIColor.black.cgColor
        permissionsShadowView.layer.shadowOpacity = 0.3
        permissionsShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        permissionsShadowView.layer.shadowRadius = 8
        permissionsShadowView.layer.shouldRasterize = true
        permissionsShadowView.layer.rasterizationScale = UIScreen.main.scale
        
        permissionsNeededLabel.alpha = 0
        permissionsNeededLabel.layer.shadowColor = UIColor.black.cgColor
        permissionsNeededLabel.layer.shadowRadius = 2.0
        permissionsNeededLabel.layer.shadowOpacity = 0.75
        permissionsNeededLabel.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        permissionsNeededLabel.layer.masksToBounds = false
        permissionsNeededLabel.layer.shouldRasterize = true
        permissionsNeededLabel.layer.rasterizationScale = UIScreen.main.scale
        
    }
    func addGraphicsView() {
        let hostingController = UIHostingController(rootView: SymbolsView())
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: expandedGraphicsReferenceView)
        
        expandedGraphicsReferenceView.transform = CGAffineTransform(rotationAngle: 30.degreesToRadians)
        
        addParallaxToView(vw: expandedGraphicsReferenceView)
    }
    func addParallaxToView(vw: UIView) {
        let amount = 50

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -9.0, 9.0, -8.0, 7.0, -5.0, 3.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
