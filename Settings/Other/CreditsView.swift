//
//  CreditsView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Credits")
                
                NavigationLink(
                    destination:
                        PeopleView()
                        .navigationBarTitle(Text("People"), displayMode: .inline)
                ) {
                    HStack {
                        Label(text: "People")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .edgePadding()
                }
                .accessibility(hint: Text("Navigate to the credits page"))
                
                Line()
                
                Button(action: {
                    Bridge.presentLicenses?()
                }) {
                    HStack {
                        Label(text: "Licenses")
                        Spacer()
                    }
                    .edgePadding()
                    .bottomRowPadding()
                }
                .accessibility(hint: Text("Present the open-source licenses that Find uses"))
            }
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        
    }
}
