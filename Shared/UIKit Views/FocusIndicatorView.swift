//
//  FocusIndicatorView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class FocusIndicatorView: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        let imageView = UIImageView()
        let image = UIImage(named: "FocusIndicator")
        imageView.image = image
        addSubview(imageView)
        imageView.pinEdgesToSuperview()
    }
}
