//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

/// `CameraToolbarView` is passed in from `CameraViewController`
struct TabBarView<PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View>: View {
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var toolbarViewModel: ToolbarViewModel
    @ObservedObject var cameraViewModel: CameraViewModel
    
    @ViewBuilder var photosSelectionToolbarView: PhotosSelectionToolbarView
    @ViewBuilder var photosDetailToolbarView: PhotosDetailToolbarView
    @ViewBuilder var listsSelectionToolbarView: ListsSelectionToolbarView
    
    var body: some View {
        Color.clear
            .overlay(
                HStack(alignment: .bottom, spacing: 0) {
                    PhotosButton(tabViewModel: tabViewModel, attributes: tabViewModel.photosIconAttributes)
                    CameraButton(tabViewModel: tabViewModel, cameraViewModel: cameraViewModel, attributes: tabViewModel.cameraIconAttributes)
                    ListsButton(tabViewModel: tabViewModel, attributes: tabViewModel.listsIconAttributes)
                }
                    .padding(.bottom, ConstantVars.tabBarOverflowingIconsBottomPadding)
                    .opacity(toolbarViewModel.toolbar == .none ? 1 : 0)
                    .overlay(
                        VStack {
                            switch toolbarViewModel.toolbar {
                            case .none:
                                EmptyView()
                            case .photosSelection:
                                photosSelectionToolbarView
                            case .photosDetail:
                                photosDetailToolbarView
                            case .listsSelection:
                                listsSelectionToolbarView
                            }
                        }
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, ConstantVars.tabBarHuggingBottomPadding)
                    )
                    .overlay(
                        CameraToolbarView(viewModel: cameraViewModel)
                            .opacity(tabViewModel.tabBarAttributes.toolbarAlpha)
                            .offset(x: 0, y: tabViewModel.tabBarAttributes.toolbarOffset)
                    )
                    .frame(height: tabViewModel.tabBarAttributes.backgroundHeight, alignment: .bottom)
                    .padding(.horizontal, 16)
                
                /// right after this point is the area of visual tab bar background (what the user sees)
                
                    .background(BackgroundView(tabViewModel: tabViewModel))
                
                , alignment: .bottom
            )
            .edgesIgnoringSafeArea(.all)
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
        .border( /// border is less glitchy than overlay
            Color(UIColor.secondaryLabel)
                .opacity(tabViewModel.tabBarAttributes.topLineAlpha),
            width: 0.5
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
