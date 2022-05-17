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
    
    /// the actual percentage used by the view
    @Published var percentage = CGFloat(0)
    
    /// `true` if the entire progress bar is visible.
    @Published var percentageShowing = false
    
    @Published var shimmerPercentage = CGFloat(0)
    @Published var shimmerShowing = false
    
    @Published var finalShimmerPercentage = CGFloat(0)
    @Published var finalShimmerShowing = false
    
    var startTime: Date?
    
    /// configuration
    var foregroundColor: UIColor = .init(hex: 0x00aeef)
    var backgroundColor: UIColor = .init(hex: 0x00aeef).withAlphaComponent(0.2)
    
    static var shimmerWidth = CGFloat(200)
    static var shimmerAnimationInterval = CGFloat(4.5)
    static var shimmerAnimationTime = CGFloat(1.5)
    static var maximumTimerDuration = CGFloat(5) /// stop the timer after this
    
    init(
        foregroundColor: UIColor = .init(hex: 0x00aeef),
        backgroundColor: UIColor = .init(hex: 0x00aeef).withAlphaComponent(0.2)
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    enum Progress {
        case determinate(progress: CGFloat)
        case auto(estimatedTime: CGFloat)
    }
    
    func start(progress: Progress) {
        startTime = Date()
        switch progress {
        case .determinate(let progress):
            percentage = progress
            withAnimation {
                percentageShowing = true
            }
        case .auto(let estimatedTime):
            withAnimation {
                percentageShowing = true
            }
            
            let interval = estimatedTime / 4
            
            /// make the animation slightly longer
            let delayedInterval = interval * 2.5
            
            withAnimation(.spring()) {
                self.percentage = 0.2
            }
            
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                if self.checkShouldInvalidate() {
                    timer.invalidate()
                    return
                }
                withAnimation(.easeOut(duration: delayedInterval)) {
                    let remaining = 0.9 - self.percentage
                    let additional = remaining * 1.5 / 5
                    self.percentage += additional
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: ProgressViewModel.shimmerAnimationInterval, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if self.checkShouldInvalidate() {
                    timer.invalidate()
                    return
                }
                self.shimmer(isFinal: false)
            }
        }
    }
    
    func updateProgress(_ newProgress: CGFloat) {
        withAnimation {
            progress = .determinate(progress: 1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                self.percentageShowing = false
            }
        }
    }
    
    func finishAutoProgress(shouldShimmer: Bool = true) {
        withAnimation(.easeIn(duration: 0.5)) {
            percentage = 1
        }
        
        if shouldShimmer {
            shimmer(isFinal: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                self.percentageShowing = false
            }
        }
    }
}

extension ProgressViewModel {
    func shimmer(isFinal: Bool) {
        if isFinal {
            finalShimmerShowing = true
            finalShimmerPercentage = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.5)) {
                    self.finalShimmerPercentage = 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 0.9)) {
                    self.shimmerShowing = false
                    self.finalShimmerShowing = false
                }
            }
        } else {
            shimmerShowing = true
            shimmerPercentage = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: ProgressViewModel.shimmerAnimationTime)) {
                    self.shimmerPercentage = 1
                }
            }
        }
    }
    
    /// true if should invalidate
    func checkShouldInvalidate() -> Bool {
        if percentage >= 1 {
            return true
        }
        if let startTime = startTime, abs(startTime.timeIntervalSinceNow) > ProgressViewModel.maximumTimerDuration {
            return true
        }
        return false
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
                            ZStack {
                                ShimmerView(
                                    showing: model.shimmerShowing,
                                    percentage: model.shimmerPercentage,
                                    screenSize: geometry.size
                                )
                                
                                ShimmerView(
                                    showing: model.finalShimmerShowing,
                                    percentage: model.finalShimmerPercentage,
                                    screenSize: geometry.size
                                )
                            }
                        )
                        .clipped(), /// clip the gradient to the bounds of the color
                    alignment: .leading
                )
        }
        .opacity(model.percentageShowing ? 1 : 0)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ShimmerView: View {
    var showing: Bool
    var percentage: CGFloat
    var screenSize: CGSize
    
    var body: some View {
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
        .drawingGroup()
        .opacity(showing ? 0.5 : 0)
        .frame(width: ProgressViewModel.shimmerWidth)
        .clipped() /// clip the gradient to its frame
        .position(shimmerOffset(screenSize: screenSize))
    }
    
    func shimmerOffset(screenSize: CGSize) -> CGPoint {
        let totalWidth = screenSize.width + ProgressViewModel.shimmerWidth
        let startingOffset = -ProgressViewModel.shimmerWidth
        let offset = startingOffset + percentage * totalWidth
        
        var position = CGPoint(x: offset, y: 0)
        position.x += ProgressViewModel.shimmerWidth / 2
        position.y += screenSize.height / 2
        return position
    }
}

struct ProgressLineViewTester: View {
    @StateObject var model = ProgressViewModel()
    var body: some View {
        ZStack {
            Color.black
            
            ProgressLineView(model: model)
                .frame(height: 5)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        model.start(progress: .auto(estimatedTime: 1))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            model.finishAutoProgress()
                        }
                    }
                }
        }
    }
}
