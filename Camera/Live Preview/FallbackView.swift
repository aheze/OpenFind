//
//  FallbackView.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// in case no camera was found
class FallbackView: UIView {
    
    var goToPhotos: (() -> Void)?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(_ sender: Any) {
        goToPhotos?()
    }
    
    @IBOutlet weak var backgroundView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FallbackView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        titleLabel.text = "No Camera Found."
        titleLabel.font = .preferredFont(forTextStyle: .title1).bold()
        
        descriptionLabel.text = "Find was not able to access the camera. Would you like to find from your photos instead?"
        descriptionLabel.font = .preferredFont(forTextStyle: .headline)
            
        
        button.setTitle("Find From Photos", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline).bold()
        button.backgroundColor = .white.withAlphaComponent(0.3)
        button.layer.cornerRadius = 12
        
        backgroundView.layer.cornerRadius = 16
    }
}

