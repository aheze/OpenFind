//
//  Utilities.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    @Binding var progress: CGFloat
    @State var blurEffectView = BlurEffectView()
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> BlurEffectView {
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            refresh()
        }
        return blurEffectView
    }
    func updateUIView(_ uiView: BlurEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.updateProgress(percentage: progress)
    }
    
    /// re-make the blur after coming back from the home screen/app switcher
    func refresh() {
        blurEffectView.setupBlur()
        blurEffectView.updateProgress(percentage: progress)
    }
}

class BlurEffectView: UIVisualEffectView {
    
    var animator: UIViewPropertyAnimator?
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        backgroundColor = .clear
        frame = superview.bounds
        setupBlur()
    }
    
    func setupBlur() {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .start)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        effect = UIBlurEffect(style: .systemUltraThinMaterialDark)

        animator?.addAnimations { [weak self] in
            self?.effect = UIBlurEffect(style: .systemThickMaterial)
        }
        animator?.fractionComplete = 0
    }
    
    func updateProgress(percentage: CGFloat) {
        animator?.fractionComplete = percentage
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
}

/// remap `Image` to the current bundle
struct Image: View {
    
    let source: Source
    enum Source {
        case assetCatalog(String)
        case systemIcon(String)
    }
    
    init(_ name: String) { self.source = .assetCatalog(name) }
    init(systemName: String) { self.source = .systemIcon(systemName) }
    
    var body: some View {
        switch source {
        case let .assetCatalog(name):
            SwiftUI.Image(name, bundle: Bundle(identifier: "com.aheze.TabBarController"))
        case let .systemIcon(name):
            SwiftUI.Image(systemName: name)
        }
    }
}

class ButtonView: UIButton {

    var tapped: (() -> Void)?
    var shouldFade = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        self.addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchFinish(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        self.addTarget(self, action: #selector(touchConfirm(_:)), for: [.touchUpInside, .touchDragEnter])
    }

    @objc func touchDown(_ sender: UIButton) {
        fade(true)
    }
    @objc func touchFinish(_ sender: UIButton) {
        fade(false)
    }
    @objc func touchConfirm(_ sender: UIButton) {
        tapped?()
    }
    
    func fade(_ fade: Bool) {
        if shouldFade {
            if fade {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


