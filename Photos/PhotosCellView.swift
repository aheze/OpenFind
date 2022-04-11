//
//  PhotosCellView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosCellView: UIView {
    lazy var imageView = UIImageView()
    
    /// if ignored, add black shade
    lazy var shadeView = UIView()
    
    lazy var overlayView = UIView()
    lazy var overlayGradientImageView = UIImageView()
    lazy var overlayStarImageView = UIImageView()
    var overlayStarImageViewLeftC: NSLayoutConstraint!
    var overlayStarImageViewBottomC: NSLayoutConstraint!
    
    lazy var selectOverlayView = UIView()
    lazy var selectOverlayIconView = SelectionIconView(configuration: .regular)
    var selectOverlayIconViewRightC: NSLayoutConstraint!
    var selectOverlayIconViewBottomC: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }
    
    func commonInit() {
        let c = PhotosCellConstants.self
        
        addSubview(imageView)
        imageView.pinEdgesToSuperview()
        
        addSubview(overlayView)
        overlayView.pinEdgesToSuperview()
        
        overlayView.addSubview(shadeView)
        shadeView.pinEdgesToSuperview()
        
        overlayView.addSubview(overlayGradientImageView)
        overlayGradientImageView.pinEdgesToSuperview()
        
        overlayView.addSubview(overlayStarImageView)
        overlayStarImageView.translatesAutoresizingMaskIntoConstraints = false
        let overlayStarImageViewLeftC = overlayStarImageView.leadingAnchor.constraint(
            equalTo: overlayView.leadingAnchor,
            constant: c.starLeftPadding
        )
        let overlayStarImageViewBottomC = overlayStarImageView.bottomAnchor.constraint(
            equalTo: overlayView.bottomAnchor,
            constant: -c.starBottomPadding
        )
        NSLayoutConstraint.activate([
            overlayStarImageViewLeftC,
            overlayStarImageViewBottomC
        ])
        self.overlayStarImageViewLeftC = overlayStarImageViewLeftC
        self.overlayStarImageViewBottomC = overlayStarImageViewBottomC
        
        /// setup
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        overlayGradientImageView.image = UIImage(named: "CellShadow")
        overlayGradientImageView.isUserInteractionEnabled = false
        overlayGradientImageView.contentMode = .scaleAspectFill
       
        /// configure constants
        shadeView.backgroundColor = Colors.accent.toColor(.black, percentage: 0.5).withAlphaComponent(0.75)
        overlayView.backgroundColor = .clear
        overlayStarImageView.image = UIImage(systemName: "star.fill")
        overlayStarImageView.tintColor = c.starTintColor
        overlayStarImageView.setIconFont(font: c.starFont)
        
        clipsToBounds = true
        
        // MARK: Selection

        selectOverlayView.backgroundColor = .clear
        addSubview(selectOverlayView)
        selectOverlayView.pinEdgesToSuperview()
        
        selectOverlayIconView.setState(.hidden)
        selectOverlayView.addSubview(selectOverlayIconView)
        selectOverlayIconView.translatesAutoresizingMaskIntoConstraints = false
        let selectOverlayIconViewRightC = selectOverlayIconView.trailingAnchor.constraint(
            equalTo: selectOverlayView.trailingAnchor,
            constant: -c.selectRightPadding
        )
        let selectOverlayIconViewBottomC = selectOverlayIconView.bottomAnchor.constraint(
            equalTo: selectOverlayView.bottomAnchor,
            constant: -c.selectBottomPadding
        )
        NSLayoutConstraint.activate([
            selectOverlayIconViewRightC,
            selectOverlayIconViewBottomC,
            selectOverlayIconView.widthAnchor.constraint(equalToConstant: 24),
            selectOverlayIconView.heightAnchor.constraint(equalToConstant: 24)
        ])
        self.selectOverlayIconViewRightC = selectOverlayIconViewRightC
        self.selectOverlayIconViewBottomC = selectOverlayIconViewBottomC
        
        /// embedded in a button view, so don't take touches
        isUserInteractionEnabled = false
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
