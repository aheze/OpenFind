//
//  ResultsIconView.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

struct ResultsIconView: View {
    @Binding var count: Int
    @State var scaleAnimationActive = false
    
    var body: some View {
        Button {
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeOut(duration: 0.3)) { scaleAnimationActive = false }
            }
        } label: {
            Text("\(count)")
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .font(.system(size: 19))
                .background(
                    Color.white.opacity(0.15)
                )
                .cornerRadius(20)
        }
    }
}
