//
//  SupportView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        HelpView()
        FeedbackView()
    }
}

struct HelpView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Help")
                
                Button(action: {
                    print("help center")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Help center")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("Tutorials")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Tutorials")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}


struct FeedbackView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Feedback")
                
                Button(action: {
                    print("Rate the app")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Rate the app")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9607843161, green: 0.8898058385, blue: 0.001397311632, alpha: 1).withAlphaComponent(0.5)), .clear]), startPoint: .trailing, endPoint: .leading)
                    )
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("I found a bug")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "I found a bug")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("I have a suggestion")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "I have a suggestion")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("I have a question")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "I have a question")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}
