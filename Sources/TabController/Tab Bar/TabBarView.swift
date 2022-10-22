//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

/// `CameraToolbarView` is passed in from `CameraViewController`
struct TabBarView: View {
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var toolbarViewModel: ToolbarViewModel
    @ObservedObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        Color.clear
            .accessibilityElement()
            .accessibilityLabel(toolbarViewModel.toolbar == nil ? "Tab bar" : "Toolbar")
            .background(
                HStack(alignment: .bottom, spacing: 0) {
                    PhotosButton(tabViewModel: tabViewModel, attributes: tabViewModel.photosIconAttributes)
                    CameraButton(tabViewModel: tabViewModel, cameraViewModel: cameraViewModel, attributes: tabViewModel.cameraIconAttributes)
                    ListsButton(tabViewModel: tabViewModel, attributes: tabViewModel.listsIconAttributes)
                }
                .padding(.bottom, tabViewModel.tabBarAttributes.iconsBottomPaddingForOverflow)
                .opacity(toolbarViewModel.toolbar == nil ? 1 : 0)
                .accessibility(hidden: toolbarViewModel.toolbar != nil)
                
                /// toolbar for other view controllers
                .overlay(
                    VStack {
                        if let toolbar = toolbarViewModel.toolbar {
                            toolbar
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.bottom, tabViewModel.tabBarAttributes.toolbarBottomPadding)
                    .padding(.horizontal, 16)
                )
                
                /// toolbar icons for camera
                .overlay(
                    CameraToolbarView(model: cameraViewModel)
                        .opacity(tabViewModel.tabBarAttributes.toolbarAlpha)
                        .offset(x: 0, y: tabViewModel.tabBarAttributes.toolbarOffset)
                        .accessibility(hidden: tabViewModel.tabState != .camera)
                )
                .frame(height: tabViewModel.tabBarAttributes.backgroundHeight, alignment: .bottom)
                .padding(.horizontal, 16)
                
                /// right after this point is the area of visual tab bar background (what the user sees)
                .background(
                    BackgroundView(tabViewModel: tabViewModel)
                        .edgesIgnoringSafeArea(.all)
                ),
                alignment: .bottom
            )
            .edgesIgnoringSafeArea(.bottom)
            .opacity(getOpacity()) /// hide the tab bar when the keyboard shows
            .offset(x: 0, y: tabViewModel.barsShown ? 0 : 200)
    }
    
    func getOpacity() -> Double {
        if !tabViewModel.barsShown {
            return 0
        } else {
            return Double(tabViewModel.tabBarOpacity)
        }
    }
}

struct BackgroundView: View {
    @ObservedObject var tabViewModel: TabViewModel
    
    var body: some View {
        ZStack {
            if Debug.tabBarAlwaysTransparent == false {
                AnimatableVisualEffectView(progress: $tabViewModel.animatorProgress)
            }
            tabViewModel.tabBarAttributes.backgroundColor.color.opacity(0.5)
        }
        .overlay(
            Color.clear
                .border( /// border is less glitchy than overlay
                    Color(UIColor.opaqueSeparator)
                        .opacity(tabViewModel.tabBarAttributes.topLineAlpha),
                    width: 0.25
                )
                .padding(-0.25)
        )
    }
}

struct AnimatableVisualEffectView: UIViewRepresentable {
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
            self?.effect = UIBlurEffect(style: .systemChromeMaterial)
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
