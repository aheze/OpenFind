//
//  FocusIconView.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/11/21.
//

import SwiftUI

struct FocusIconView: View {
    @Binding var isOn: Bool
    @State var scaleAnimationActive = false
    
    var body: some View {
        Button {
            withAnimation {
                isOn.toggle()
            }
            
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeOut(duration: 0.3)) { scaleAnimationActive = false }
            }
        } label: {
            Image(systemName: "viewfinder")
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .frame(width: 40, height: 40)
                .foregroundColor(isOn ? Color(Constants.activeIconColor) : .white)
                .font(.system(size: 19))
                .background(
                    Color.white.opacity(0.15)
                )
                .cornerRadius(20)
        }
    }
}


