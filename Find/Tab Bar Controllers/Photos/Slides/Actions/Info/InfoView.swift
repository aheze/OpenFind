//
//  InfoView.swift
//  Find
//
//  Created by Zheng on 1/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import MobileCoreServices // << for UTI types
import SwiftUI

class InfoViewHoster: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        
        var infoView = InfoView()
        
        infoView.donePressed = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let hostedInfo = UIHostingController(rootView: infoView)
        
        self.addChild(hostedInfo)
        view.addSubview(hostedInfo.view)
        hostedInfo.view.frame = view.bounds
        hostedInfo.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedInfo.didMove(toParent: self)
    }
}
struct InfoView: View {
    
    var donePressed: (() -> Void)?
    
    var dateTaken = "January 1, 2020 at 3:46 PM"
    var origin = "Saved from Find"
    var isStarred = false
    var isCached = false
    var transcript = """
    textdsfop sdif osd fsod'pspdf sd'fis d['i sdf[ sdf dsf dsf dsf dsf sdds sd
                        axWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
    
    Text(isStarred ? LocalizedStringKey("Yes") : LocalizedStringKey("No"))
        .foregroundColor(Color(UIColor.secondaryLabel))
        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 16))
    
    Text("Cached?")
        .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
    
    Text(isCached ? LocalizedStringKey("Yes") : LocalizedStringKey("No"))
        .foregroundColor(Color(UIColor.secondaryLabel))
        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 16))
    """
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Date taken")
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
                    
                    Text(dateTaken)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 16))
                    
                    Text("Origin")
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
                    
                    Text(origin)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 16))
                    
                    Text("Starred?")
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
                    
                    Text(isStarred ? LocalizedStringKey("Yes") : LocalizedStringKey("No"))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 16))
                    
                    Text("Cached?")
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
                    
                    Text(isCached ? LocalizedStringKey("Yes") : LocalizedStringKey("No"))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 2, trailing: 16))
                    
                    HStack {
                        Text("Transcript (beta)")
                            .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
                        
                        Button(action: {
                            print("copy")
                            UIPasteboard.general.setValue(transcript,
                                       forPasteboardType: kUTTypePlainText as String)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(isCached ? Color(UIColor(named: "PhotosText")!) : Color(UIColor.secondaryLabel))
                                .font(Font.system(size: 19, weight: .bold))
                        }
                        .padding(.leading, 6)
                        .disabled(!isCached)
                        
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 2, trailing: 16))
                    
                    Text(transcript)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(Font(UIFont.systemFont(ofSize: 19, weight: .regular)))

                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 16))
                        .fixedSize(horizontal: false, vertical: true)
                        
                }
            }
            .navigationBarTitle("Info")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        donePressed?()
                                    }) {
                                        Text("Done")
                                            .foregroundColor(Color(UIColor(named: "PhotosText")!))
                                    }
            )
        }
    }
}

struct InfoView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
