//
//  CacheButton.swift
//  FindTabBar
//
//  Created by Zheng on 12/28/20.
//

import UIKit

class CacheButton: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var cacheIcon: CacheIcon!
    @IBOutlet weak var button: UIButton!
    
    var pressed: (() -> Void)?
    
    @IBAction func touchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 0.5
        })
    }
    @IBAction func touchUpInside(_ sender: Any) {
        resetAlpha()
        pressed?()
    }
    @IBAction func touchUpCancel(_ sender: Any) {
        resetAlpha()
    }
    
    func resetAlpha() {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 1
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CacheButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = blurView.bounds.width / 2
        shadeView.layer.cornerRadius = shadeView.bounds.width / 2
    }
}
