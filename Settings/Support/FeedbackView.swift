//
//  FeedbackView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import SupportDocs

struct FeedbackView: View {
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(text: "Feedback")
            
            
            NavigationLink(
                destination:
                    
                    /**
                     Push to the web view when tapped.
                     */
                WebViewContainer(url: URL(string: "https://forms.gle/agdyoB9PFfnv8cU1A")!, progressBarOptions: SupportOptions.ProgressBar(foregroundColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), backgroundColor: UIColor.clear))
                    .navigationBarTitle(Text("Report a bug / suggestions"), displayMode: .inline)
                    .edgesIgnoringSafeArea([.leading, .bottom, .trailing]) /// Allow the web view to go under the home indicator, on devices similar to the iPhone X.
            ) {
                HStack(spacing: 0) {
                    Label(text: "Report a bug / suggestions")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .edgePadding()
            }
            .accessibility(hint: Text("Navigate to a feedback form. Only fill in what you want."))
            
            Line()
            
            NavigationLink(
                destination:
                    ContactView()
                    .navigationBarTitle(Text("Contact"), displayMode: .inline)
            ) {
                HStack(spacing: 0) {
                    Label(text: "Contact")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .edgePadding()
            }
            .accessibility(hint: Text("Navigate to my contact page"))
            .bottomRowPadding()
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}


