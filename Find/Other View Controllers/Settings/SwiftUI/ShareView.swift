//
//  ShareView.swift
//  Find
//
//  Created by Zheng on 2/13/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct HeaderViewWithRightText: View {
    var text: LocalizedStringKey
    var body: some View {
        
        HStack {
            Text(text)
                .foregroundColor(.white)
                .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
            
            Spacer()
            
            Text(":)")
                .foregroundColor(.white)
                .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
            
        }
        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(#colorLiteral(red: 0.04306942655, green: 0.04306942655, blue: 0.04306942655, alpha: 0.9)))
        .accessibility(addTraits: .isHeader)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Share Find\n :)"))
    }
}
struct ShareView: View {
    @Binding var isShowingQR: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderViewWithRightText(text: "Share Find")
            
            HStack(spacing: 14) {
                Button(action: {
                    
                    SettingsHoster.viewController?.shareApp()
                    
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
struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView(isShowingQR: .constant(false))
            .previewLayout(.fixed(width: 414, height: 200))
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
                
                Text("getfind.app")
                    .foregroundColor(Color.white)
                    .font(.system(size: 21, weight: .medium))
                    .padding(.bottom, 20)
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPresented = false
                    }
                }) {
                    Text("Dismiss")
                        .foregroundColor(Color.white)
                        .font(.system(size: 19, weight: .regular))
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
