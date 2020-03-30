//
//  HelpControllers.swift
//  Find
//
//  Created by Zheng on 2/21/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import WebKit
import SwiftyJSON

class HelpObject: NSObject {
    var title = ""
    var urlPath = ""
}
//Proto
class DefaultHelpController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    var arrayOfHelp = [String]()
//    var indexToData = [String]()
    
    var helpObjects = [HelpObject]()
    var helpJsonKey = "ListsHelpArray"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var currentPath = -1
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        helpObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCellID") as! HelpCell
//        cell.nameLabel.text = arrayOfHelp[indexPath.row]
        let object = helpObjects[indexPath.row]
        cell.nameLabel.text = object.title
        print("deleg, \(object.title)")
        
        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let sizeOfWidth = tableView.bounds.width - 32
//        let baseHeight = arrayOfHelp[indexPath.row].heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 18))
//        return baseHeight + 32
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentPath = indexPath.row
        performSegue(withIdentifier: "showHelpController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHelpController" {
            print("help pressed")
            let destinationVC = segue.destination as! HelpController
            destinationVC.urlString = helpObjects[currentPath].urlPath
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        tableView.alpha = 0
        tableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeTapped))
        if let url = URL(string: "https://raw.githubusercontent.com/zjohnzheng/FindHelp/master/1NavigatorDatasource.json") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                
               if let data = data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        if let data = jsonString.data(using: .utf8) {
                            if let json = try? JSON(data: data) {
                                for item in json[self.helpJsonKey].arrayValue {
//                                    print("ITEM: \(item)")
                                    let name = item["name"].stringValue
                                    let urlString = item["url"].stringValue
                                    
                                    let newHelpObject = HelpObject()
                                    newHelpObject.title = name
                                    newHelpObject.urlPath = urlString
                                    
                                    self.helpObjects.append(newHelpObject)
                                    print("name: \(name), url: \(urlString)")
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
//                        print("OBJECTS: \(self.helpObjects)")
//                        self.tableView.performBatchUpdates({
                            self.tableView.reloadData()
//                        }, completion: { _ in
                            UIView.animate(withDuration: 0.3, animations: {
                                self.tableView.alpha = 1
                                self.tableView.transform = CGAffineTransform.identity
                            })
//                        })
                    }
                }
                
            }.resume()
        }
        
        

    }
    
    
    @objc func closeTapped() {
        SwiftEntryKit.dismiss()
    }
}

class HelpCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
}
class HelpController: UIViewController, WKNavigationDelegate {
    
    private var estimatedProgressObserver: NSKeyValueObservation?

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
//        progressBar.progressTintColor = #colorLiteral(red: 0.9764705896, green: 0.5311594379, blue: 0, alpha: 1)
        
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
            let errorUrlToLoad = URL(string: "https://zjohnzheng.github.io/FindHelp/404.html")!
            let myRequest = URLRequest(url: errorUrlToLoad)
            webView.load(myRequest)
        }
        
    }
    
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         if navigationAction.navigationType == WKNavigationType.linkActivated {
             print("link")

            
            
             decisionHandler(WKNavigationActionPolicy.cancel)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HelpController") as? HelpController
            if let url = navigationAction.request.url {
//                print("URL STINRG:::\(url.absoluteString)") // It will give the selected link URL
                vc?.urlString = url.absoluteString
            }
            self.navigationController?.pushViewController(vc!, animated: true)
            
             return
         }
//         print("no link")
         decisionHandler(WKNavigationActionPolicy.allow)
  }

}

extension HelpController {
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
