//
//  SingleHelp.swift
//  Find
//
//  Created by Zheng on 3/30/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import WebKit
import SwiftEntryKit

class SingleHelp: UIViewController, WKNavigationDelegate {
        
    private var estimatedProgressObserver: NSKeyValueObservation?
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    
    
    var urlString = ""
    var topLabelText = "Help"
    var topViewColor = UIColor.orange
        
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.largeTitleDisplayMode = .never
            
    //        progressBar.progressTintColor = #colorLiteral(red: 0.9764705896, green: 0.5311594379, blue: 0, alpha: 1)
            topLabel.text = topLabelText
            topView.backgroundColor = topViewColor
            
            webView.navigationDelegate = self
            setupEstimatedProgressObserver()
            webView.isOpaque = false
            webView.backgroundColor = UIColor.clear
            
            sendRequest(urlString: urlString)
            
        }
        private func sendRequest(urlString: String) {
            
            if let urlToLoad = URL(string: urlString) {
                let myRequest = URLRequest(url: urlToLoad)
                webView.load(myRequest)
            } else {
                topLabel.text = "Encountered an error"
                let errorUrlToLoad = URL(string: "https://zjohnzheng.github.io/FindHelp/404.html")!
                let myRequest = URLRequest(url: errorUrlToLoad)
                webView.load(myRequest)
            }
            
            
        }


    }

extension SingleHelp {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        if progressBar.isHidden {
            // Make sure our animation is visible.
            progressBar.isHidden = false
        }

        UIView.animate(withDuration: 0.33,
                       animations: {
                           self.progressBar.alpha = 1.0
        })
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        UIView.animate(withDuration: 0.33,
                       animations: {
                           self.progressBar.alpha = 0.0
                       },
                       completion: { isFinished in
                           // Update `isHidden` flag accordingly:
                           //  - set to `true` in case animation was completly finished.
                           //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                           self.progressBar.isHidden = isFinished
        })
    }
    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            UIView.animate(withDuration: 0.6, animations: {
//                self?.progressBar.progress = Float(webView.estimatedProgress)
                self?.progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
            })
            
        }
    }
}
