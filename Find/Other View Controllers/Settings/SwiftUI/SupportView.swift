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
        navigationBar: .init(
            title: "Help",
            titleColor: UIColor.white,
            dismissButtonTitle: "Done",
            buttonTintColor: UIColor.white,
            backgroundColor: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        ),
        searchBar: .init(
            placeholder: "Type here to find",
            placeholderColor: UIColor.white.withAlphaComponent(0.75),
            textColor: UIColor.white,
            tintColor: UIColor.green,
            backgroundColor: UIColor.white.withAlphaComponent(0.3),
            clearButtonMode: .whileEditing
        ),
        progressBar: .init(
            foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),
            backgroundColor: UIColor.systemBackground
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
                    print("help center")
                    helpPresented = true
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Help center")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
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
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
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
                    print("Rate the app")
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
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("I found a bug")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "I found a bug")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("I have a suggestion")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "I have a suggestion")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    print("I have a question")
                }) {
                    HStack(spacing: 0) {
                        Label(text: "I have a question")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}
