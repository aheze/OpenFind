//
//  MessageView.swift
//  FindTabBar
//
//  Created by Zheng on 12/28/20.
//

import UIKit

class MessageView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var shadeView: UIView!
    
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var labelButton: UIButton!
    @IBOutlet weak var morphingLabel: LTMorphingLabel!
    
    var currentMessageIdentifier: UUID?
    
    @IBAction func touchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.labelButton.alpha = 0.5
        })
    }
    @IBAction func touchUpInside(_ sender: Any) {

        resetAlpha()
    }
    @IBAction func touchUpCancel(_ sender: Any) {
        resetAlpha()
    }
    
    func resetAlpha() {
        UIView.animate(withDuration: 0.2, animations: {
            self.morphingLabel.alpha = 1
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
        Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 8
        
        morphingLabel.morphingEffect = LTMorphingEffect.evaporate
        
        shadeView.alpha = 0
        labelContainerView.alpha = 0
        blurView.effect = nil
        
        self.isUserInteractionEnabled = false
    }
    
    
    func showMessage(_ message: String, dismissible: Bool, duration: Int) {
        let thisMessageIdentifier = UUID()
        morphingLabel.text = message
        
        UIView.animate(withDuration: 0.8) {
            self.shadeView.alpha = 1
            self.labelContainerView.alpha = 1
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        
        if duration >= 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
                if thisMessageIdentifier == self.currentMessageIdentifier {
                    self.hideMessages()
                }
            }
        }
        
    }
    func updateMessage(_ message: String) {
        DispatchQueue.main.async {
            self.morphingLabel.text = message
        }
    }
    func unHideMessages() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8) {
                self.shadeView.alpha = 1
                self.labelContainerView.alpha = 1
                self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            }
        }
    }
    func hideMessages() {
        DispatchQueue.main.async {
            self.currentMessageIdentifier = nil
            UIView.animate(withDuration: 0.8) {
                self.shadeView.alpha = 0
                self.labelContainerView.alpha = 0
                self.blurView.effect = nil
            }
        }
    }
}
