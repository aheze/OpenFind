//
//  SearchVC+Extras.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI
import WebKit

extension SearchViewController {
    static let extrasPopoverTag = "Extras"

    func checkExtras(text: String) {
        // MARK: - Commands

        if text.roughlyEquals("/resetAddedListsBefore") {
            realmModel.addedListsBefore = false
            showPopover(configuration: .message(icon: "checkmark", text: "Reset Added Lists Before"), autoDismiss: true)
        }

        if text.roughlyEquals("/resetLaunchedBefore") {
            realmModel.launchedBefore = false
            showPopover(configuration: .message(icon: "checkmark", text: "Reset Launched Before"), autoDismiss: true)
        }

        if text.roughlyEquals("/resetStartedVersions") {
            realmModel.startedVersions = []
            showPopover(configuration: .message(icon: "checkmark", text: "Reset Started Versions"), autoDismiss: true)
        }

        if text.roughlyEquals("/resetEnteredVersions") {
            realmModel.enteredVersions = []
            showPopover(configuration: .message(icon: "checkmark", text: "Reset Entered Versions"), autoDismiss: true)
        }

        if text.roughlyEquals("/resetPoints") {
            realmModel.experiencePoints = 0
            showPopover(configuration: .message(icon: "checkmark", text: "Reset Experience Points"), autoDismiss: true)
        }

        if text.roughlyEquals("/showAddedListsBefore") {
            showPopover(configuration: .message(icon: "info.circle", text: "Added Lists Before? \(realmModel.addedListsBefore)"), autoDismiss: true)
        }

        if text.roughlyEquals("/showLaunchedBefore") {
            showPopover(configuration: .message(icon: "info.circle", text: "Launched Before? \(realmModel.launchedBefore)"), autoDismiss: true)
        }

        if text.roughlyEquals("/showStartedVersions") {
            showPopover(configuration: .message(icon: "info.circle", text: "Started Versions? \(realmModel.startedVersions)"), autoDismiss: true)
        }

        if text.roughlyEquals("/showEnteredVersions") {
            showPopover(configuration: .message(icon: "info.circle", text: "Entered Versions: \(realmModel.enteredVersions)"), autoDismiss: true)
        }

        if text.roughlyEquals("/showPoints") {
            showPopover(configuration: .message(icon: "info.circle", text: "Experience Points: \(realmModel.experiencePoints)"), autoDismiss: true)
        }

        if text.roughlyEquals("/debugPopulateWithLotsOfPhotos") {
            let strings = [
                "Some string",
                "as diuoiasu oisud oaisdu aosd",
                "ieufn oisufoisdufiodsuf oidsfusidfu sd",
                "alksdj asdjlajdlkasjdlkasjd lksajdlkajsdlka jdkljsldkjalksdj alksjdklasd",
                "asdjh saodjklasdkla string",
                "Some adskj",
                "longsdklfj sdfkjsdlf dsf"
            ]

            for i in 0..<1_000 {
                Debug.log("Populating: \(i)")
                let string = strings.randomElement()!
                let sentences = (0..<250).map { _ in
                    Sentence(
                        string: string,
                        confidence: 1,
                        topLeft: CGPoint(x: 0.9998, y: 0.933),
                        topRight: CGPoint(x: 0.9998, y: 0.933),
                        bottomRight: CGPoint(x: 0.9998, y: 0.933),
                        bottomLeft: CGPoint(x: 0.9998, y: 0.93343)
                    )
                }
                let photoMetadata = PhotoMetadata(
                    assetIdentifier: UUID().uuidString,
                    isStarred: Bool.random(),
                    isIgnored: false,
                    dateScanned: Date()
                )

                let text = PhotoMetadataText(
                    sentences: sentences,
                    scannedInLanguages: [Settings.Values.RecognitionLanguage.english.rawValue],
                    scannedInVersion: "2.0.3"
                )

                realmModel.container.updatePhotoMetadata(metadata: photoMetadata, text: text)
            }
            showPopover(configuration: .message(icon: "info.circle", text: "Populated."), autoDismiss: true)
        }

        if text.roughlyEquals("/debugDeleteAllMetadatas") {
            ViewControllerCallback.deleteAllScannedData?(false)
            showPopover(configuration: .message(icon: "info.circle", text: "Deleted All Scanned Data."), autoDismiss: true)
        }

        if text.roughlyEquals("/debugDeleteAllPhotos") {
            ViewControllerCallback.deleteAllScannedData?(true)
            showPopover(configuration: .message(icon: "info.circle", text: "Deleted All Photo Metadata."), autoDismiss: true)
        }

        // MARK: - Extras

        if text.roughlyEquals("/about") {
            showPopover(configuration: .about, autoDismiss: false)
        }

        if text.roughlyEquals("/help") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let viewController = SettingsData.getHelpCenter?() {
                    self.present(viewController, animated: true)
                }
                self.view.endEditing(true)
            }
        }

        if text.roughlyEquals("/flip") {
            UIView.animate(
                duration: 1.8,
                dampingFraction: 1
            ) {
                guard let mainView = UIApplication.rootViewController?.view else { return }
                mainView.transform = mainView.transform.rotated(by: CGFloat.pi)
                mainView.transform = mainView.transform.rotated(by: CGFloat.pi)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view.endEditing(true)
            }
        }

        if text.roughlyEquals("/rick") {
            if let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ") {
                showPopover(configuration: .url(url: url), autoDismiss: false)
            }
        }

        if text.roughlyEquals("/tre") {
            if let url = URL(string: "https://www.youtube.com/channel/UCNtulabnRs8kwfIFFKy9hQQ?app=desktop") {
                showPopover(configuration: .link(url: url, icon: "tv.fill", text: "Tre's channel"), autoDismiss: false)
            }
        }

        if text.roughlyEquals("/etsy") {
            if let url = URL(string: "https://www.etsy.com/shop/StuffingStuff") {
                showPopover(configuration: .link(url: url, icon: "scissors", text: "Buy crochet stuff!"), autoDismiss: false)
            }
        }

//        if text.roughlyEquals("/coco") {
//            if let url = URL(string: "https://www.youtube.com/c/cocomelonarmy") {
//                showPopover(configuration: .link(url: url, icon: "tv.fill", text: "Sub to cocomelon"), autoDismiss: false)
//            }
//        }

        if text.roughlyEquals("/apple") {
            showPopover(configuration: .image(systemName: "applelogo"), autoDismiss: true)
        }
    }

    func showPopover(configuration: ExtrasView.Configuration, autoDismiss: Bool) {
        var attributes = Popover.Attributes()
        attributes.tag = SearchViewController.extrasPopoverTag
        attributes.position = .relative(popoverAnchors: [.top])
        attributes.sourceFrame = { UIScreen.main.bounds }

        var insets = Global.safeAreaInsets
        insets.top += 160
        insets.left += 32
        insets.right += 32
        attributes.sourceFrameInset = insets

        let searchConfiguration = searchViewModel.configuration
        let popover = Popover(attributes: attributes) {
            ExtrasView(searchConfiguration: searchConfiguration, configuration: configuration)
        }
        if let existingPopover = view.popover(tagged: SearchViewController.extrasPopoverTag) {
            replace(existingPopover, with: popover)
        } else {
            present(popover)
        }

        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let existingPopover = self.view.popover(tagged: SearchViewController.extrasPopoverTag) {
                    self.dismiss(existingPopover)
                }
            }
        }
    }
}

struct ExtrasView: View {
    enum Configuration {
        case message(icon: String, text: String)
        case about
        case url(url: URL)
        case link(url: URL, icon: String, text: String) /// show a popup first, then open in safari
        case image(systemName: String)
    }

    var searchConfiguration: SearchConfiguration
    var configuration: Configuration

    @State var transform: SettingsProfileTransformState?
    var body: some View {
        switch configuration {
        case .message(icon: let icon, text: let text):
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(UIFont.systemFont(ofSize: 52, weight: .semibold).font)

                Text(text)
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
            }
            .padding(36)
            .foregroundColor(searchConfiguration.popoverTextColor.color)
            .background(VisualEffectView(searchConfiguration.popoverBackgroundBlurStyle))
            .cornerRadius(20)
        case .about:
            VStack(spacing: 16) {
                Button {
                    withAnimation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.6,
                            blendDuration: 1
                        )
                    ) {
                        if transform == nil {
                            transform = SettingsProfileTransformState.allCases.randomElement()
                        } else {
                            transform = nil
                        }
                    }
                } label: {
                    PortraitView(length: 180, circular: true, transform: $transform)
                }
                .buttonStyle(LaunchButtonStyle())

                Group {
                    Text("Made by Andrew Zheng")

                    Button {
                        if let url = URL(string: "https://twitter.com/intent/user?screen_name=aheze0") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Follow me on Twitter!")
                            .opacity(0.75)
                    }
                }
                .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                .foregroundColor(searchConfiguration.fieldIsDark ? UIColor.white.color : UIColor.secondaryLabel.color)
            }
            .padding(36)
            .background(VisualEffectView(searchConfiguration.popoverBackgroundBlurStyle))
            .cornerRadius(20)
        case .url(url: let url):
            WebView(url: url)
                .frame(height: 200)
                .frame(maxWidth: 350)
                .cornerRadius(10)
                .shadow(color: UIColor.systemBackground.color.opacity(0.25), radius: 4, x: 0, y: 2)
        case .link(url: let url, icon: let icon, text: let text):
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(UIFont.systemFont(ofSize: 84, weight: .semibold).font)

                Text(text)
                    .frame(maxWidth: .infinity)

                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Text("Open URL")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                        .background(Color.accent)
                        .cornerRadius(16)
                }
            }
            .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
            .foregroundColor(searchConfiguration.fieldIsDark ? UIColor.white.color : UIColor.secondaryLabel.color)
            .padding(36)
            .background(VisualEffectView(searchConfiguration.popoverBackgroundBlurStyle))
            .cornerRadius(20)
        case .image(systemName: let systemName):
            Image(systemName: systemName)
                .font(UIFont.systemFont(ofSize: 84, weight: .semibold).font)
                .foregroundColor(searchConfiguration.fieldIsDark ? UIColor.white.color : UIColor.secondaryLabel.color)
                .padding(36)
                .aspectRatio(1, contentMode: .fill)
                .background(VisualEffectView(searchConfiguration.popoverBackgroundBlurStyle))
                .cornerRadius(20)
        }
    }
}

private extension String {
    func roughlyEquals(_ otherText: String) -> Bool {
        let a = filter { !$0.isWhitespace }.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let b = otherText.filter { !$0.isWhitespace }.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return a == b
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let view = WKWebView()
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        view.load(request)

        return view
    }

    func updateUIView(_ view: WKWebView, context: UIViewRepresentableContext<WebView>) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        view.load(request)
    }
}
