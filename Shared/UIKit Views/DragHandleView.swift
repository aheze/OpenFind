//
//  DragHandleView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class DragHandleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.layer.cornerRadius = bounds.height / 2
    }
    
    private func commonInit() {
        backgroundColor = .clear
    }
    
    var pressed: (() -> Void)?
    var released: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard
            let touch = touches.first,
            let event = event,
            event?.type == .touches
        else { return }
        
        let location = touch.location(in: nil)
        
        print("Touches began!: \(location)")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard
            let touch = touches.first,
            let event = event,
            event?.type == .touches
        else { return }
        
        let location = touch.location(in: nil)
        
        print("Touches moved!: \(location)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard
            let touch = touches.first,
            let event = event,
            event?.type == .touches
        else { return }
        
        let location = touch.location(in: nil)
        
        print("Touches ended!: \(location)")
    }
}
