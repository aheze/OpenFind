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
            percentage = 0
            
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: interval + 0.2)) {
                    self.percentage = 0.2
                }
            }
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
                
                guard let self = self else { return }
                print("add. \(self.percentage)")
                
                withAnimation(.easeOut(duration: interval + 0.2)) {
                    let remaining = 0.9 - self.percentage
                    let additional = remaining * 2 / 5
                    self.percentage += additional
                }
                //                if randomNumber == 10 {
                //                    timer.invalidate()
                //                }
            }
        }
    }
    
    func updateProgress(_ newProgress: CGFloat) {
        withAnimation {
            progress = .determinate(progress: 1)
        }
    }
    
    func finishAutoProgress() {
        withAnimation(.linear(duration: 0.9)) {
            progress = .auto(estimatedTime: 1)
        }
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
                    , alignment: .leading
                )
        }
    }
}

struct ProgressLineViewTester: View {
    @StateObject var model = ProgressViewModel(progress: .auto(estimatedTime: 1.5))
    var body: some View {
        ProgressLineView(model: model)
    }
}
