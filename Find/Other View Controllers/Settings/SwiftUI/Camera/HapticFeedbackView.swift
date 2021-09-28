//
//  HapticFeedbackView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct HapticFeedbackView: View {
    @Binding var level: Int
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Haptic Feedback")
                    .accessibility(hint: Text("Vibrate the phone when results are found"))
                
                HStack(spacing: 14) {
                    Button(action: {
                        level = 1
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: (level == 1) ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))))
                                .frame(height: 36)
                            
                            Label(text: "None")
                            
                        }
                    }
                    .accessibility(addTraits:
                        level == 1
                            ? [.isButton, .isSelected]
                            : .isButton
                    )
                    
                    Button(action: {
                        level = 2
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: (level == 2) ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))))
                                .frame(height: 36)
                            Label(text: "Light")
                        }
                    }
                    .accessibility(addTraits:
                        level == 2
                            ? [.isButton, .isSelected]
                            : .isButton
                    )
                    
                    Button(action: {
                        level = 3
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: (level == 3) ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))))
                                .frame(height: 36)
                            Label(text: "Heavy")
                            
                            
                        }
                    }
                    .accessibility(addTraits:
                        level == 3
                            ? [.isButton, .isSelected]
                            : .isButton
                    )
                }
                
                .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}
