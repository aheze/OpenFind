//
//  CameraViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI
import TabBarController

class CameraViewController: UIViewController, PageViewController {
    var tabType: TabState = .camera
    var toolbar = ToolbarView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
//            toolbar =
    }
}

struct ToolbarView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack {
                ToolbarButton(iconName: "arrow.up.left.and.arrow.down.right")
                Spacer()
                ToolbarButton(iconName: "bolt.slash.fill")
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                ToolbarButton(iconName: "viewfinder")
                Spacer()
                ToolbarButton(iconName: "gearshape.fill")
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ToolbarButton: View {
    var iconName: String
    var body: some View {
        Button {
            print("Pressed")
        } label: {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 19))
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.15))
                .cornerRadius(20)
        }
    }
}



