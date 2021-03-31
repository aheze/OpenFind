//
//  SupportView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI
import SupportDocs

struct SupportView: View {
    var body: some View {
        HelpView()
        FeedbackView()
    }
}

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
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Help")
                
                Button(action: {
                    helpPresented = true
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Help Center")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Present the help center"))
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("Tutorials")
                    tutorialsPresented = true
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Tutorials")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Rewatch the \"Quick Tour\" tutorials"))
                
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        .sheet(isPresented: $helpPresented, content: {
            SupportDocsView(dataSourceURL: dataSource, options: options, isPresented: $helpPresented)
        })
        .actionSheet(isPresented: $tutorialsPresented, content: {
            ActionSheet(title: Text("watchTutorial"), message: Text("whichTutorialWatch"), buttons: [
                .default(Text("generalTutorial")) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "GeneralTutorialViewController") as! GeneralTutorialViewController
                    SettingsHoster.viewController?.present(vc, animated: true, completion: nil)
                },
                .default(Text("photosTutorial")) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTutorialViewController") as! HistoryTutorialViewController
                    SettingsHoster.viewController?.present(vc, animated: true, completion: nil)
                },
                .default(Text("listsTutorial")) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ListsTutorialViewController") as! ListsTutorialViewController
                    SettingsHoster.viewController?.present(vc, animated: true, completion: nil)
                },
                .default(Text("listsBuilderTutorial")) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ListsBuilderTutorialViewController") as! ListsBuilderTutorialViewController
                    SettingsHoster.viewController?.present(vc, animated: true, completion: nil)
                },
                .cancel()
            ])
        })
    }
}


struct FeedbackView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Feedback")
                
                Button(action: {
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
                    HStack(spacing: 0) {
                        Label(text: "Rate the app")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9607843161, green: 0.8898058385, blue: 0.001397311632, alpha: 1).withAlphaComponent(0.5)), .clear]), startPoint: .trailing, endPoint: .leading)
                    )
                }
                .accessibility(hint: Text("Open the App Store to rate Find. Thanks!"))
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
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
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Navigate to a feedback form. Only fill in what you want."))
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                NavigationLink(
                    destination:
                    ContactView()
                        .navigationBarTitle(Text("Contact"), displayMode: .inline)
                ) {
                    HStack(spacing: 0) {
                        Label(text: "Contact")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Navigate to my contact page"))
                
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}
