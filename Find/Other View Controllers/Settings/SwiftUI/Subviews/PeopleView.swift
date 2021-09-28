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
            Color(.black).brightness(0.1).edgesIgnoringSafeArea(.all)
            
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
                    
                    Text("Find by Andrew Zheng")
                        .foregroundColor(.white)
                        .font(Font(UIFont.systemFont(ofSize: 24, weight: .medium)))
                    
                    Text("Hello there! Thanks for checking out Find, really appreciate it!")
                        .foregroundColor(.white)
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 6, leading: 32, bottom: 16, trailing: 32))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 14) {
                        ProfileButton(imageName: "IconMedium", link: "https://aheze.medium.com")
                        ProfileButton(imageName: "IconGitHub", link: "https://github.com/aheze")
                        ProfileButton(imageName: "IconReddit", link: "https://www.reddit.com/user/aheze")
                        ProfileButton(imageName: "IconDiscord", link: "https://discord.com/invite/UJpHv8jmN5")
                        ProfileButton(imageName: "IconEmail", link: "mailto:aheze@getfind.app")
                        
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
                    
                    PersonWidget(
                        urlString: "https://hkamran.com/",
                        imageName: "HKamran",
                        name: "H. Kamran",
                        description: Text("hkamranDesc"),
                        urlText: "hkamran.com"
                    )
                    .padding(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    
                    PersonWidget(
                        urlString: "https://soundcloud.com/winksounds",
                        imageName: "WinK",
                        name: "W in K",
                        description: Text("winkDesc"),
                        urlText: "soundcloud.com/winksounds"
                    )
                    .padding(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    
                }
                .padding(.bottom, 24)
            }
        }
    }
}

struct ProfileButton: View {
    var imageName: String
    var link: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(Color.white)
        }
    }
}

struct PersonWidget: View {
    let urlString: String
    let imageName: String
    let name: String
    let description: Text
    let urlText: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(alignment: .top) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(
                        Circle()
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))]), startPoint: .bottom, endPoint: .top),
                                lineWidth: 4)
                            .background(Circle().foregroundColor(Color.clear))
                    )
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(name)
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 20, leading: 6, bottom: 2, trailing: 20))
                    
                    description
                        .fixedSize(horizontal: false, vertical: true)
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                        .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 6, trailing: 20))
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Text(urlText)
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
        .buttonStyle(PlainButtonStyle())
    }
    
}

struct PeopleView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        PeopleView()
    }
}
