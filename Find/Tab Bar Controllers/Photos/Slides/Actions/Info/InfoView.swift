//
//  InfoView.swift
//  Find
//
//  Created by Zheng on 1/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import MobileCoreServices // << for UTI types
import SwiftUI
import SwiftEntryKit

class InfoViewHoster: UIViewController {
    
    var dateTaken = "January 1, 2020 at 3:46 PM"
    var origin = "Saved from Find"
    var isStarred = false
    var isCached = false
    var transcript = ""
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pressedDone: (() -> Void)?
    
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        
        var infoView = InfoView()
        
        infoView.donePressed = { [weak self] in
            self?.pressedDone?()
            self?.dismiss(animated: true, completion: nil)
        }
        
        infoView.dateTaken = dateTaken
        infoView.origin = origin
        infoView.isStarred = isStarred
        infoView.isCached = isCached
        infoView.transcript = transcript
        
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
    var transcript = ""
    
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
                        Text("Transcript")
                            .font(Font(UIFont.systemFont(ofSize: 19, weight: .bold)))
                        
                        Button(action: {
                            UIPasteboard.general.setValue(transcript,
                                       forPasteboardType: kUTTypePlainText as String)
                           
                            let topToast = UIView()
                            topToast.backgroundColor = UIColor.systemBackground
                            topToast.layer.cornerRadius = 25
                            
                            let contentView = UIView()
                            let imageView = UIImageView()
                            let titleLabel = UILabel()
                            
                            topToast.addSubview(contentView)
                            
                            let configuration = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium, scale: .default)
                            imageView.image = UIImage(systemName: "doc.on.doc", withConfiguration: configuration)?.withTintColor(UIColor(named: "PhotosText")!, renderingMode: .alwaysOriginal)
                            
                            let copied = NSLocalizedString("copied", comment: "")
                            titleLabel.text = copied
                            titleLabel.textColor = UIColor(named: "PhotosText")
                            titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
                            
                            contentView.addSubview(imageView)
                            contentView.addSubview(titleLabel)
                            
                            contentView.snp.makeConstraints { (make) in
                                make.center.equalToSuperview()
                            }
                            
                            imageView.snp.makeConstraints { (make) in
                                make.left.equalToSuperview()
                                make.top.equalToSuperview()
                                make.bottom.equalToSuperview()
                                make.width.equalTo(24)
                                make.height.equalTo(24)
                            }
                            
                            titleLabel.snp.makeConstraints { (make) in
                                make.left.equalTo(imageView.snp.right).offset(6)
                                make.centerY.equalToSuperview()
                                make.right.equalToSuperview()
                            }
                            
                            var attributes = EKAttributes.topToast
                            attributes.displayDuration = 1.2
                            attributes.entryInteraction = .dismiss
                            attributes.shadow = .active(with: .init(color: EKColor(#colorLiteral(red: 0.6370837092, green: 0.6370837092, blue: 0.6370837092, alpha: 1)), opacity: 0.2, radius: 10, offset: CGSize(width: 2, height: 1)))
                            
                            attributes.positionConstraints.size = .init(width: .constant(value: 150), height: .constant(value: 50))
                            
                            SwiftEntryKit.display(entry: topToast, using: attributes)
                            
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
                                            .font(Font.system(size: 19, weight: .regular, design: .default))
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
