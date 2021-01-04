//
//  SettingsComponents.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct Label: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
    }
}
/// Header for each section
struct SectionHeaderView: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .font(Font(UIFont.systemFont(ofSize: 17, weight: .medium)))
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 0, trailing: 0))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct HeaderView: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 4))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(#colorLiteral(red: 0.04306942655, green: 0.04306942655, blue: 0.04306942655, alpha: 0.9)))
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

extension String {
    static let customRed = "FF3939"
    static let customOrange = "FF8B00"
    static let customYellow = "FFDC00"
    static let customGreen = "34D425"
    
    static let customBlue = "00AEEF"
    static let customDarkBlue = "005EDC"
    static let customPurple = "6555FF"
    static let customMagenta = "DB55FF"
    
    static let customSalmon = "FF7979"
    static let customYellorange = "FFBF2C"
    static let customLime = "E0FF64"
    static let customNeon = "30FF6F"
    
    static let customLightBlue = "5EB7FF"
    static let customMediumBlue = "2E8DFF"
    static let customLightPurple = "B77AFF"
    static let customPink = "FF779F"
}
