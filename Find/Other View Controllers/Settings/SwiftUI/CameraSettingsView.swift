//
//  CameraView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct CameraSettingsView: View {
    @Binding var textDetectionIsOn: Bool
    @Binding var hapticFeedbackLevel: Int
    @Binding var livePreviewEnabled: Bool
    var body: some View {
        TextDetectionView(isOn: $textDetectionIsOn)
        HapticFeedbackView(level: $hapticFeedbackLevel)
        LivePreviewView(isOn: $livePreviewEnabled)
    }
}

struct TextDetectionView: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Text Detection Indicator")
                
                HStack(spacing: 0) {
                    if isOn {
                        Label(text: "ON")
                    } else {
                        Label(text: "OFF")
                    }
                    Spacer()
                    Toggle(isOn: $isOn, label: {
                        Text("Label")
                    }).labelsHidden()

                }
                .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}

struct HapticFeedbackView: View {
    @Binding var level: Int
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Haptic Feedback")
                
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
                    Button(action: {
                        level = 2
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: (level == 2) ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))))
                                .frame(height: 36)
                            Label(text: "Light")
                        }
                    }
                    Button(action: {
                        level = 3
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: (level == 3) ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))))
                                .frame(height: 36)
                            Label(text: "Heavy")
                            
                            
                        }
                    }
                }
                
                .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}

struct LivePreviewView: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Live Preview")
                
                HStack(spacing: 0) {
                    if isOn {
                        Label(text: "ON")
                    } else {
                        Label(text: "OFF")
                    }
                    Spacer()
                    Toggle(isOn: $isOn, label: {
                        Text("Label")
                    }).labelsHidden()

                }
                .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}

