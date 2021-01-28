//
//  WebView.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 10/16/20.
//

import SwiftUI
import WebKit

/**
 The web view, with a progress bar at the top.
 
 This is presented when a cell is tapped (in the main page).
*/
internal struct WebViewContainer: View {
    
    /// URL to load.
    var url: URL
    
    /// Stores the background and foreground color of the progress bar.
    var progressBarOptions: SupportOptions.ProgressBar
    
    /**
     Callback from the `WKNavigationDelegate`.
     - `pageTitle` - the name of the page (supplied in the `Title` property at the top of your GitHub Pages).
     - `progress` - get how much the page is loaded.
     - `estimatedProgressObserver` - the observer that keeps track of the page load progress.
     - `nextUrl` - the url of the next page. Used when a link is pressed.
     - `presentNextPage` - determines whether a new page should be presented (when a link is pressed).
    */
    @ObservedObject var webViewStateModel: WebViewStateModel = WebViewStateModel()
    
    var body: some View {
        ZStack(alignment: .center) {
            
            /// First, the Web View at the bottom of everything.
            WebView(url: url, webViewStateModel: self.webViewStateModel)
            
            /// Then, the progress bar at the top of the screen.
            VStack {
                
                /// Reads the value inside `$webViewStateModel.progress`.
                /// This is set inside the `NSKeyValueObservation` as the page loads.
                ProgressBar(value: $webViewStateModel.progress, progressBarOptions: progressBarOptions)
                    .frame(height: 3)
                Spacer()
            }
            
            /**
             When the user clicks a link, open it in a new page.
             
             The new page is pushed when `$webViewStateModel.presentNextPage` is true.
             */
            NavigationLink(destination: WebViewContainer(url: webViewStateModel.nextUrl ?? URL(string: "https://aheze.github.io/SupportDocs/404")!, progressBarOptions: progressBarOptions), isActive: $webViewStateModel.presentNextPage) {
                
                /// No need for a button (it's presented automatically based on `$webViewStateModel.presentNextPage`)
                EmptyView()
            }
        }
    }
}


/**
 Callback from the `WKNavigationDelegate`.
 - `pageTitle` - the name of the page (supplied in the `Title` property at the top of your GitHub Pages).
 - `progress` - get how much the page is loaded.
 - `estimatedProgressObserver` - the observer that keeps track of the page load progress.
 - `nextUrl` - the url of the next page. Used when a link is pressed.
 - `presentNextPage` - determines whether a new page should be presented (when a link is pressed).
 
 Source: [https://medium.com/macoclock/how-to-use-webkit-webview-in-swiftui-4b944d04190a](https://medium.com/macoclock/how-to-use-webkit-webview-in-swiftui-4b944d04190a).
 */
internal class WebViewStateModel: ObservableObject {
    @Published var pageTitle: String = "Web View"
    @Published var progress: Float = 0
    @Published var estimatedProgressObserver: NSKeyValueObservation?
    
    @Published var nextUrl: URL?
    @Published var presentNextPage = false
}

/**
 The SwiftUI WebView.
 
 Made possible with `UIViewRepresentable` and `WebViewStateModel: ObservableObject` for delegate callback.
 */
internal struct WebView: View {
     enum NavigationAction {
           case decidePolicy(WKNavigationAction,  (WKNavigationActionPolicy) -> Void)
           case didStartProvisionalNavigation(WKNavigation)
           case didFinish(WKNavigation)
       }
       
    /// Callback for the SwiftUI view.
    @ObservedObject var webViewStateModel: WebViewStateModel
    
    /// Load the web view with this.
    let uRLRequest: URLRequest
    
    var body: some View {
        
        /// Return the `UIViewRepresentable`.
        WebViewWrapper(webViewStateModel: webViewStateModel,
                       request: uRLRequest)
    }
    
    init(url: URL, webViewStateModel: WebViewStateModel) {
        self.uRLRequest = URLRequest(url: url)
        self.webViewStateModel = webViewStateModel
    }
}

/**
 WKWebView ported over to SwiftUI with `UIViewRepresentable`.
 */
internal final class WebViewWrapper: UIViewRepresentable {
    
    /// Port the `WKNavigationDelegate` delegate over to SwiftUI.
    @ObservedObject var webViewStateModel: WebViewStateModel
    
    let request: URLRequest
    
    init(webViewStateModel: WebViewStateModel, request: URLRequest) {
        self.request = request
        self.webViewStateModel = webViewStateModel
    }
    
    /// `UIViewRepresentable` required function #1.
    func makeUIView(context: Context) -> WKWebView  {
        let view = WKWebView()
        view.isOpaque = false
        view.navigationDelegate = context.coordinator
        view.load(request)
        
        let webCoordinator = context.coordinator
        webCoordinator.webView = view
        return view
    }
      
    /// `UIViewRepresentable` required function #2, but no need for this in our case.
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    /// `UIViewRepresentable` function for making the delegate.
    func makeCoordinator() -> Coordinator {
        return Coordinator(webViewStateModel: webViewStateModel)
    }
    
    /// The `Coordinator` for managing the `WKNavigationDelegate` delegate.
    final class Coordinator: NSObject {
        @ObservedObject var webViewStateModel: WebViewStateModel
        var webView: WKWebView? {
            didSet {
                setupEstimatedProgressObserver()
            }
        }
        init(webViewStateModel: WebViewStateModel) {
            self.webViewStateModel = webViewStateModel
        }
    }
}

/**
 `WKNavigationDelegate` used for getting loading progress and handling links.
 */
extension WebViewWrapper.Coordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        /**
         If the user presses a link, open it in a new page (push a new page onto the `NavigationView`.
         */
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            decisionHandler(WKNavigationActionPolicy.cancel)
            if let url = navigationAction.request.url {
                
                /// Set the URL to present.
                webViewStateModel.nextUrl = url
                
                /// Set `webViewStateModel.presentNextPage` to true so the `NavigationView` pushes the new page.
                webViewStateModel.presentNextPage = true
                
            }
        } else {
            
            /// Not likely to happen, but allow anyway.
            decisionHandler(.allow)
        }
    }
    
    /// The page started loading, so set the progress bar's progress a bit.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.webViewStateModel.progress = Float(0.15)
    }
    
    /// The page finished loading, and the `title` is available.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let title = webView.title {
            webViewStateModel.pageTitle = title
        }
    }
    
    /// Set up the progress observer (for updating the progress bar).
    private func setupEstimatedProgressObserver() {
        webViewStateModel.estimatedProgressObserver = webView?.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            let progress = max(Float(webView.estimatedProgress), 0.2)
            self?.webViewStateModel.progress = progress
        }
    }
}
