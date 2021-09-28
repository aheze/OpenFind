//
//  ExternalLinks.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct ExternalLinks: View {
    var body: some View {
        VStack {
            Button(action: {
                print("Rate the app")
                
                if let productURL = URL(string: "https://apps.apple.com/app/id1506500202") {
                    var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
                    
                    // 2.
                    components?.queryItems = [
                        URLQueryItem(name: "action", value: "write-review")
                    ]
                    
                    // 3.
                    guard let writeReviewURL = components?.url else {
                        print("no url")
                        return
                    }
                    
                    // 4.
                    UIApplication.shared.open(writeReviewURL)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(Font.system(size: 24, weight: .medium))
                    Text("Rate the App")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .foregroundColor(.white)
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    LinearGradient(gradient: Gradient(colors: [ Color(#colorLiteral(red: 0.9686274529, green: 0.5967518268, blue: 0.1745674654, alpha: 1)), Color(#colorLiteral(red: 0.9529411793, green: 0.7149735081, blue: 0.1333333403, alpha: 1))]), startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(12)
            }
            .accessibility(hint: Text("Open the App Store to rate Find. Thanks!"))
            
            
            Button(action: {
                if let serverURL = URL(string: "https://apps.apple.com/app/id1506500202") {
                    UIApplication.shared.open(serverURL)
                }
            }) {
                HStack(spacing: 12) {
                    Image("Discord")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Join the Discord")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .foregroundColor(.white)
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3450980392, green: 0.3960784314, blue: 0.9490196078, alpha: 1)), Color(#colorLiteral(red: 0.3377238396, green: 0.3960784314, blue: 0.9490196078, alpha: 1))]), startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(12)
            }
            .accessibility(hint: Text("Join the Discord Server, where you can chat with fellow Finders and get support."))
        }
    }
}
