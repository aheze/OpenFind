//
//  CreditsView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct PeopleView: View {
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.1326085031, green: 0.1326085031, blue: 0.1326085031, alpha: 1)).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    Image("Zheng")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))]), startPoint: .bottom, endPoint: .top),
                                    lineWidth: 6)
                                .background(Circle().foregroundColor(Color.clear))
                        )
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 6, trailing: 20))
                    
                    Text("Find by Zheng")
                        .foregroundColor(.white)
                        .font(Font(UIFont.systemFont(ofSize: 24, weight: .medium)))
                    
                    HStack(spacing: 14) {
                        Button(action: {
                            if let url = URL(string: "https://aheze.medium.com/") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image("MediumIcon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.white)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://github.com/aheze") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image("GitHubIcon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.white)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://www.reddit.com/user/aheze") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image("RedditIcon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.white)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://discord.com/users/743230678795288637") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image("DiscordIcon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.white)
                        }
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 0.5)
                            .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                            .frame(height: 1)
                            .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 6))
                        
                        Text("Thanks to")
                            .foregroundColor(.white)
                        
                        RoundedRectangle(cornerRadius: 0.5)
                            .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                            .frame(height: 1)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 20))
                    }
                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    
                    Button(action: {
                        if let url = URL(string: "https://hkamran.com/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(alignment: .top) {
                            Image("HKamran")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))]), startPoint: .bottom, endPoint: .top),
                                            lineWidth: 4)
                                        .background(Circle().foregroundColor(Color.clear))
                                )
                                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("H. Kamran")
                                    .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 20, leading: 6, bottom: 2, trailing: 20))
                                
                                Text("Beta tester")
                                    .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                                    .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 6, trailing: 20))
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("hkamran.com")
                                        .font(Font(UIFont.systemFont(ofSize: 14, weight: .medium)))
                                        .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 6, trailing: 6))
                                }
                            }
                            
                            Spacer()
                        }
                        .background(Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1).withAlphaComponent(0.5)))
                        .cornerRadius(12)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 4, trailing: 20))
                    
                    Button(action: {
                        if let url = URL(string: "https://soundcloud.com/winksounds") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(alignment: .top) {
                            Image("WinK")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))]), startPoint: .bottom, endPoint: .top),
                                            lineWidth: 4)
                                        .background(Circle().foregroundColor(Color.clear))
                                )
                                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("W in K")
                                    .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 20, leading: 6, bottom: 2, trailing: 20))
                                
                                Text("Made the app promo music")
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                                    .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 6, trailing: 20))
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("soundcloud.com/winksounds")
                                        .font(Font(UIFont.systemFont(ofSize: 14, weight: .medium)))
                                        .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 6, trailing: 6))
                                }
                            }
                            
                            Spacer()
                        }
                        .background(Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1).withAlphaComponent(0.5)))
                        .cornerRadius(12)
                    }
                    .padding(EdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20))
                    
                }
            }
        }
    }
}

struct PeopleView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        PeopleView()
    }
}
