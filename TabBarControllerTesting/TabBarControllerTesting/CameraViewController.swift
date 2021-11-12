//
//  CameraViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI
import TabBarController

class CameraState: ObservableObject {
    @Published var resultsCount = 0
    @Published var flashOn = false
    @Published var focusOn = false
}

class CameraViewController: UIViewController, PageViewController {
    var tabType: TabState = .camera
    var cameraState: CameraState!
    lazy var toolbar: ToolbarView = {
        self.cameraState = CameraState()
        toolbar = ToolbarView(cameraState: cameraState)
        return toolbar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
}

struct ToolbarView: View {
    @ObservedObject var cameraState: CameraState
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack {
                ResultsIconView(count: $cameraState.resultsCount)
                Spacer()
                FlashIconView(isOn: $cameraState.flashOn)
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                FocusIconView(isOn: $cameraState.focusOn)
                Spacer()
                SettingsIconView()
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



