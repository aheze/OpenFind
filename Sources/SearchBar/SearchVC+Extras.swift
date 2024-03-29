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

        if text.roughlyEquals("/debugDeleteAllMetadatas") {
            ViewControllerCallback.deleteAllScannedData?(false)
            showPopover(configuration: .message(icon: "info.circle", text: "Deleted All Scanned Data."), autoDismiss: true)
        }

        if text.roughlyEquals("/debugDeleteAllPhotos") {
            ViewControllerCallback.deleteAllScannedData?(true)
            showPopover(configuration: .message(icon: "info.circle", text: "Deleted All Photo Metadata."), autoDismiss: true)
        }

        if text.roughlyEquals("/debugDeleteAllNotes") {
            ViewControllerCallback.deleteAllNotes?()
            showPopover(configuration: .message(icon: "info.circle", text: "Deleted All Photo Notes."), autoDismiss: true)
        }

        // MARK: - Extras

        if text.roughlyEquals("/set") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view.endEditing(true)
            }

            ViewControllerCallback.presentSettings?()
        }

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

        if text.roughlyEquals("/apple") {
            showPopover(configuration: .image(systemName: "applelogo"), autoDismiss: true)
        }

        if text.roughlyEquals("/coco") {
            if let url = URL(string: "https://www.youtube.com/c/cocomelonarmy") {
                showPopover(configuration: .link(url: url, icon: "tv.fill", text: "Sub to cocomelon"), autoDismiss: false)
            }
        }

        if text.roughlyEquals("/strawberry") {
            showPopover(configuration: .strawberry, autoDismiss: false)
        }

        if text.roughlyEquals("/gradient") {
            showPopover(configuration: .gradient, autoDismiss: false)
        }

        if text.roughlyEquals("/code") {
            showPopover(configuration: .code, autoDismiss: false)
        }

        if text.roughlyEquals("/launch") {
            showPopover(
                configuration: .button(
                    title: "Show Launch Screen",
                    description: "View the launch screen again!",
                    buttonTitle: "Launch",
                    action: { [weak self] in
                        guard let self = self else { return }
                        self.presentLaunchViewController(type: .swiftUI)
                    }
                ),
                autoDismiss: false
            )
        }

        if text.roughlyEquals("/legacyLaunch") {
            showPopover(
                configuration: .button(
                    title: "Show Launch Screen Animation",
                    description: "This is the legacy launch screen from version 2.0.5. Disclaimer: app performance could get worse, view at your own risk!",
                    buttonTitle: "Launch",
                    action: { [weak self] in
                        guard let self = self else { return }
                        self.presentLaunchViewController(type: .realityKit)
                    }
                ),
                autoDismiss: false
            )
        }
    }

    func presentLaunchViewController(type: LaunchViewModel.SceneType) {
        let model = LaunchViewModel()
        model.sceneType = type

        let launchViewController = LaunchViewController.make(model: model)
        launchViewController.modalPresentationStyle = .overFullScreen
        present(launchViewController, animated: true)

        launchViewController.done = { [weak launchViewController] in
            if let launchViewController = launchViewController {
                launchViewController.dismiss(animated: false)
            }
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

        func dismiss() {
            if let existingPopover = view.popover(tagged: SearchViewController.extrasPopoverTag) {
                self.dismiss(existingPopover)
            }
        }

        let searchConfiguration = searchViewModel.configuration
        let popover = Popover(attributes: attributes) {
            ExtrasView(searchConfiguration: searchConfiguration, configuration: configuration) {
                dismiss()
            }
        }
        if let existingPopover = view.popover(tagged: SearchViewController.extrasPopoverTag) {
            replace(existingPopover, with: popover)
        } else {
            present(popover)
        }

        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
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
        case strawberry
        case gradient
        case code
        case button(title: String, description: String, buttonTitle: String, action: (() -> Void)?)
    }

    var searchConfiguration: SearchConfiguration
    var configuration: Configuration
    var dismiss: (() -> Void)?

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
        case .strawberry:
            getStrawberryView()
        case .gradient:
            GradientView()
        case .code:
            CodeView()
        case .button(title: let title, description: let description, buttonTitle: let buttonTitle, action: let action):
            VStack(spacing: 16) {
                Image(systemName: "info.circle")
                    .font(UIFont.systemFont(ofSize: 84, weight: .semibold).font)

                Text(title)
                    .frame(maxWidth: .infinity)

                Text(description)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .opacity(0.75)

                Button {
                    dismiss?()
                    action?()
                } label: {
                    Text(buttonTitle)
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
        }
    }

    func getStrawberryView() -> AnyView {
        if #available(iOS 15.0, *) {
            return AnyView(StrawberryView())
        } else {
            return AnyView(EmptyView())
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

@available(iOS 15.0, *)
struct StrawberryView: View {
    var body: some View {
        Button {
            print("Strawberry")
        } label: {
            AsyncImage(url: URL(string: "https://thumbs.dreamstime.com/b/fresh-strawberry-white-background-40742985.jpg"))
        }
    }
}

struct GradientView: View {
    var body: some View {
        VStack {
            ForEach(0 ..< 10, id: \.self) { b in
                Color(
                    UIColor(red: 1, green: 0, blue: CGFloat(b) / 10, alpha: 1)
                )
            }
        }
    }
}

struct CodeView: View {
    @State var color = Color.blue
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)

            Text("Hello Coding Club!")
                .foregroundColor(color)

            Button {
                color = .green
            } label: {
                Text("Hehehaha")
            }
        }
        .background(UIColor.systemBackground.color)
    }
}
