//
//  ContactView.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct ContactView: View {
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.1326085031, green: 0.1326085031, blue: 0.1326085031, alpha: 1)).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    Text("gotQuestionsContact")
                        .foregroundColor(Color.white)
                        .font(Font.system(size: 19, weight: .regular))
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    
                    ContactWidget(
                        urlString: "https://discord.com/users/743230678795288637",
                        startColor: #colorLiteral(red: 0.4470588235, green: 0.537254902, blue: 0.8549019608, alpha: 1),
                        endColor: #colorLiteral(red: 0.2784313725, green: 0.4392156863, blue: 1, alpha: 1),
                        title: "DM me on Discord",
                        subtitle: "aheze#3125",
                        imageName: "DiscordIcon"
                    )
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                    
                    
                    ContactWidget(
                        urlString: "https://www.reddit.com/user/aheze",
                        startColor: #colorLiteral(red: 1, green: 0.5529411765, blue: 0, alpha: 1),
                        endColor: #colorLiteral(red: 1, green: 0.3411764706, blue: 0, alpha: 1),
                        title: "DM me on Reddit",
                        subtitle: "aheze#3125",
                        imageName: "RedditIcon"
                    )
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                    
                    ContactWidget(
                        urlString: "mailto:aheze@getfind.app",
                        startColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
                        endColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),
                        title: "Email me",
                        subtitle: "aheze@getfind.app",
                        imageName: "EmailIcon"
                    )
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                    
                }
            }
        }
    }
}


struct ContactWidget: View {
    let urlString: String
    let startColor: UIColor
    let endColor: UIColor
    let title: String
    let subtitle: String
    let imageName: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 0) {
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: .init(colors: [Color(startColor), Color(endColor)]),
                                startPoint: .init(x: 0.5, y: 0),
                                endPoint: .init(x: 0.5, y: 0.6)
                            )
                        )
                        .frame(maxWidth: 100)
                    
                    Image(imageName)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color.white)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .foregroundColor(Color.white)
                        .font(Font.system(size: 19, weight: .medium))
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 2, trailing: 16))
                    
                    Text(subtitle)
                        .foregroundColor(Color.white.opacity(0.75))
                        .font(Font.system(size: 19, weight: .medium))
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(#colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 0.2)))
            .cornerRadius(12)
        }
    }
}
