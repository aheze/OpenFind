//
//  InfoView.swift
//  Find
//
//  Created by Zheng on 1/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("hi")
                }
            }
        }
    }
}
