//
//  ShareView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct ShareView: View {
    @Binding var isShowingQR: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderViewWithRightText(text: "Share Find")
            
            HStack(spacing: 14) {
                Button(action: {
                    
                    Bridge.presentShareScreen?()
                    
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: .init(colors: [Color(#colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)), Color(#colorLiteral(red: 0.05098039216, green: 0.462745098, blue: 0.8941176471, alpha: 1))]),
                                startPoint: .init(x: 0.5, y: 0),
                                endPoint: .init(x: 0.5, y: 1)
                            )
                        )
                        .frame(height: 65)
                        
                        HStack {
                            Image(systemName: "link")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color.white)
                            
                            Text("Link")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .accessibility(hint: Text("Presents a share sheet to share Find's website link"))
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowingQR = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                gradient: .init(colors: [Color(#colorLiteral(red: 0, green: 0.8470588235, blue: 0.4, alpha: 1)), Color(#colorLiteral(red: 0.01176470588, green: 0.5803921569, blue: 0, alpha: 1))]),
                                startPoint: .init(x: 0.5, y: 0),
                                endPoint: .init(x: 0.5, y: 1)
                            )
                        )
                        .frame(height: 65)
                        
                        HStack {
                            Image(systemName: "qrcode")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color.white)
                            
                            Text("QR Code")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color.white)
                        }
                        
                    }
                }
                .accessibility(hint: Text("Presents a QR code"))
                
            }
            
            .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}


struct QRCodeView: View {
    @Binding var isPresented: Bool
    var body: some View {
        
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            VStack(spacing: 20) {
                Image("AppQRCode")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: 300, maxHeight: 300)
                    .accessibility(label: Text("QR Code"))
                
                
                Button(action: {
                    if let url = URL(string: "https://www.getfind.app/") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("getfind.app")
                        .foregroundColor(Color.white)
                        .font(.system(size: 26, weight: .medium))
                }
                .accessibility(hint: Text("Open Find's website in browser"))
                .padding(.bottom, 20)
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPresented = false
                    }
                }) {
                    Text("Dismiss")
                        .foregroundColor(Color.white)
                        .font(.system(size: 19, weight: .regular))
                        .opacity(0.5)
                }
                .accessibility(hint: Text("Return to Settings screen"))
            }
            
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) {
                isPresented = false
            }
        }
    }
}
