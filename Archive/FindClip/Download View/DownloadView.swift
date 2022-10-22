//
//  DownloadView.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import SwiftUI

struct DownloadView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Free, no ads or in-app purchases")
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                        
                    FeatureWidget(
                        imageName: "photo.on.rectangle.angled",
                        imageColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),
                        title: "Photos",
                        description: "Find from hundreds of photos in minutes."
                    )
                    
                    FeatureWidget(
                        imageName: "list.bullet",
                        imageColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),
                        title: "Lists",
                        description: "Group words together. Look for all of them at the same time."
                    )
                    
                    FeatureWidget(
                        imageName: "greetingcard",
                        imageColor: #colorLiteral(red: 0.19009358, green: 0.5517816681, blue: 0.7882612179, alpha: 1),
                        title: "Caching",
                        description: "Cache your photos for super-fast, super-accurate results."
                    )
                    
                    FeatureWidget(
                        imageName: "gearshape",
                        imageColor: #colorLiteral(red: 0.4719796309, green: 0.2557317915, blue: 0.9151041667, alpha: 1),
                        title: "Settings",
                        description: "Customize Find to your liking. Check out stats."
                    )
                    
                    FeatureWidget(
                        imageName: "ellipsis",
                        imageColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
                        title: "And much more",
                        description: "Download now!",
                        makeLink: true
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.bottom, 180)
            }
            .fixFlickering { scrollView in
                scrollView
                    .background(
                        Color(UIColor(named: "DarkBackground") ?? UIColor.white)
                    )
            }
            .configureBar()
            .navigationTitle("Get the full app")
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct FeatureWidget: View {
    var imageName: String
    var imageColor: UIColor
    var title: String
    var description: String
    var makeLink: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: imageName)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color(imageColor))
                .cornerRadius(18)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 21, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                if makeLink {
                    Button(action: {
                        if let url = URL(string: "https://as.getfind.app/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(description)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color(#colorLiteral(red: 0.8414442274, green: 1, blue: 1, alpha: 1)))
                            .opacity(0.8)
                    }
                } else {
                    Text(description)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView()
    }
}
