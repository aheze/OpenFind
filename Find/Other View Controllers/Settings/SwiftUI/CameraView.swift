//
//  CameraView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct CameraSettingsView: View {
    var body: some View {
        TextDetectionView()
        HapticFeedbackView()
        LivePreviewView()
    }
}

struct TextDetectionView: View {
    @State var isOn = false
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
    @State var mode = 0
    
    @State var none = true
    @State var light = false
    @State var heavy = false
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Haptic Feedback")
                
                HStack(spacing: 14) {
                    Button(action: {
                        none = true
                        light = false
                        heavy = false
                        mode = 0
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: none ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))))
                                .frame(height: 36)
                            
                            Label(text: "None")
                            
                        }
                    }
                    Button(action: {
                        none = false
                        light = true
                        heavy = false
                        mode = 1
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: light ? 3 : 0)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))))
                                .frame(height: 36)
                            Label(text: "Light")
                        }
                    }
                    Button(action: {
                        none = false
                        light = false
                        heavy = true
                        mode = 2
                    }) {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.blue, lineWidth: heavy ? 3 : 0)
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
    @State var isOn = false
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

