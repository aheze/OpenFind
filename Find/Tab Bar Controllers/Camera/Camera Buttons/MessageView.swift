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
    @IBOutlet weak var labelButton: UIButton!
    
    var messagesShown = 0
    
    @IBAction func touchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.labelButton.alpha = 0.5
        })
    }
    @IBAction func touchUpInside(_ sender: Any) {
        print("Message view pressed")
        resetAlpha()
    }
    @IBAction func touchUpCancel(_ sender: Any) {
        resetAlpha()
    }
    
    func resetAlpha() {
        UIView.animate(withDuration: 0.2, animations: {
            self.labelButton.alpha = 1
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
        
        self.shadeView.alpha = 0
        self.labelButton.alpha = 0
        self.blurView.effect = nil
    }
    
    func showMessage(_ message: String, dismissible: Bool, duration: Int) {
        labelButton.setTitle(message, for: .normal)
        messagesShown += 1
        UIView.animate(withDuration: 0.8) {
            self.shadeView.alpha = 1
            self.labelButton.alpha = 1
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        
        if duration >= 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
                self.messagesShown -= 1
                
                if self.messagesShown == 0 {
                    self.hideMessages()
                }
            }
        } else {
            self.messagesShown -= 1
        }
        
    }
    func hideMessages() {
        UIView.animate(withDuration: 0.8) {
            self.shadeView.alpha = 0
            self.labelButton.alpha = 0
            self.blurView.effect = nil
        }
    }
}
