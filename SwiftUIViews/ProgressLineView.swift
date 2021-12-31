//
//  ProgressLineView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//


import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var progress = Progress.determinate(progress: 0)
    @Published var foregroundColor: UIColor = UIColor(hex: 0x00aeef)
    @Published var backgroundColor: UIColor = UIColor(hex: 0x00aeef).withAlphaComponent(0.3)
    
    /// the actual percentage used by the view
    @Published var percentage = CGFloat(0)
    @Published var shimmerPercentage = CGFloat(0)
    @Published var shimmerShowing = false
    
    static var shimmerWidth = CGFloat(200)
    static var shimmerAnimationInterval = CGFloat(4.5)
    static var shimmerAnimationTime = CGFloat(1.5)
    
    enum Progress {
        case determinate(progress: CGFloat)
        case auto(estimatedTime: CGFloat)
    }
    
    init(
        progress: Progress,
        foregroundColor: UIColor = UIColor(hex: 0x00aeef),
        backgroundColor: UIColor = UIColor(hex: 0x00aeef).withAlphaComponent(0.3)
    ) {
        self.progress = progress
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        
        switch progress {
        case .determinate(let progress):
            percentage = progress
        case .auto(let estimatedTime):
            
            let interval = estimatedTime / 4
            
            /// make the animation slightly longer
            let delayedInterval = interval * 5 / 4
            percentage = 0
            
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: delayedInterval)) {
                    self.percentage = 0.2
                }
                self.shimmer()
            }
            
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                if self.percentage >= 1 {
                    timer.invalidate()
                    return
                }
                withAnimation(.easeOut(duration: delayedInterval)) {
                    let remaining = 0.9 - self.percentage
                    let additional = remaining * 2 / 5
                    self.percentage += additional
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: ProgressViewModel.shimmerAnimationInterval, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if self.percentage >= 1 {
                    timer.invalidate()
                    withAnimation(.linear(duration: 0.9)) {
                        self.shimmerShowing = false
                    }
                    return
                }
                self.shimmer()
            }
        }
    }
    
    
    func shimmer(speed: CGFloat = ProgressViewModel.shimmerAnimationTime) {
            self.shimmerShowing = true
            self.shimmerPercentage = 0
            withAnimation(.easeIn(duration: speed)) {
                self.shimmerPercentage = 1
            }
    }
    
    func updateProgress(_ newProgress: CGFloat) {
        withAnimation {
            progress = .determinate(progress: 1)
        }
    }
    
    func finishAutoProgress() {
        withAnimation(.easeIn(duration: 0.5)) {
            percentage = 1
        }
        shimmer(speed: 0.5)
    }
}

struct ProgressLineView: View {
    @ObservedObject var model: ProgressViewModel
    var body: some View {
        GeometryReader { geometry in
            Color(model.backgroundColor)
                .overlay(
                    Color(model.foregroundColor)
                        .frame(width: geometry.size.width * model.percentage)
                        .overlay(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0), location: 0),
                                    .init(color: Color.white.opacity(1), location: 0.5),
                                    .init(color: Color.white.opacity(1), location: 0.8),
                                    .init(color: Color.white.opacity(0), location: 1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                                .opacity(model.shimmerShowing ? 0.5 : 0)
                                .frame(width: ProgressViewModel.shimmerWidth)
                                .clipped() /// clip the gradient to its frame
                                .position(shimmerOffset(screenSize: geometry.size))
                        )
                        .clipped() /// clip the gradient to the bounds of the color
                    , alignment: .leading
                )
        }
    }
    
    func shimmerOffset(screenSize: CGSize) -> CGPoint {
        
        let totalWidth = screenSize.width + ProgressViewModel.shimmerWidth
        let startingOffset = -ProgressViewModel.shimmerWidth
        let offset = startingOffset + model.shimmerPercentage * totalWidth
        
        var position = CGPoint(x: offset, y: 0)
        position.x += ProgressViewModel.shimmerWidth / 2
        position.y += screenSize.height / 2
        return position
    }
}

struct ProgressLineViewTester: View {
    @StateObject var model = ProgressViewModel(progress: .auto(estimatedTime: 1))
    var body: some View {
        ProgressLineView(model: model)
            .frame(height: 5)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    model.finishAutoProgress()
                }
            }
    }
}
