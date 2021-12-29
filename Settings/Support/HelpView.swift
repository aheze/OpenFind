//
//  HelpView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import SupportDocs

struct HelpView: View {
    
    let dataSource = URL(string: "https://raw.githubusercontent.com/aheze/FindInfo/DataSource/_data/supportdocs_datasource.json")!
    let options = SupportOptions(
        categories: [
            .init(tag: "settings", displayName: "Settings"),
            .init(tag: "photos", displayName: "Photos"),
            .init(tag: "lists", displayName: "Lists")
        ],
        navigationBar: .init(
            title: NSLocalizedString("Help Center", comment: ""),
            titleColor: UIColor.white,
            dismissButtonTitle: NSLocalizedString("done", comment: ""),
            buttonTintColor: UIColor.white,
            backgroundColor: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        ),
        searchBar: .init(
            placeholder: NSLocalizedString("plainTypeToFind", comment: ""),
            placeholderColor: UIColor.white.withAlphaComponent(0.75),
            textColor: UIColor.white,
            tintColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
            backgroundColor: UIColor.white.withAlphaComponent(0.3),
            clearButtonMode: .whileEditing
        ),
        progressBar: .init(
            foregroundColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
            backgroundColor: UIColor.clear
        ),
        listStyle: .insetGroupedListStyle,
        navigationViewStyle: .defaultNavigationViewStyle,
        other: .init(
            activityIndicatorStyle: UIActivityIndicatorView.Style.large,
            error404: URL(string: "https://aheze.github.io/FindInfo/404")!
        )
    )
    
    @State var helpPresented = false
    
    @State var tutorialsPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(text: "Help")
            
            Button(action: {
                helpPresented = true
            }) {
                HStack(spacing: 0) {
                    Label(text: "Help Center")
                    Spacer()
                }
            }
            .edgePadding()
            .accessibility(hint: Text("Present the help center"))
            
            Line()
            
            Button(action: {

                tutorialsPresented = true
            }) {
                HStack(spacing: 0) {
                    Label(text: "Tutorials")
                    Spacer()
                }
            }
            .edgePadding()
            .accessibility(hint: Text("Rewatch the \"Quick Tour\" tutorials"))
            .bottomRowPadding()
            
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        .sheet(isPresented: $helpPresented, content: {
            SupportDocsView(dataSourceURL: dataSource, options: options, isPresented: $helpPresented)
        })
        .actionSheet(isPresented: $tutorialsPresented, content: {
            ActionSheet(title: Text("watchTutorial"), message: Text("whichTutorialWatch"), buttons: [
                .default(Text("generalTutorial")) {
                    Bridge.presentGeneralTutorial?()
                },
                .default(Text("photosTutorial")) {
                    Bridge.presentPhotosTutorial?()
                },
                .default(Text("listsTutorial")) {
                    Bridge.presentListsTutorial?()
                },
                .default(Text("listsBuilderTutorial")) {
                    Bridge.presentListsBuilderTutorial?()
                },
                .cancel()
            ])
        })
    }
}
