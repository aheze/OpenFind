// The MIT License (MIT)
//
// Copyright (c) 2015 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(iOS)
import UIKit

open class CarteViewController: UITableViewController {
  open lazy var items = Carte.items
  open var configureDetailViewController: ((CarteDetailViewController) -> Void)?

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("Open Source Licenses", comment: "Open Source Licenses")
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.adjustLeftBarButtonItemIfNeeded()
  }

  private func adjustLeftBarButtonItemIfNeeded() {
    guard self.navigationItem.leftBarButtonItem == nil else { return }

    let isPresented = (self.presentingViewController != nil)
    if isPresented {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(self.doneButtonDidTap)
      )
    }
  }

  @objc open dynamic func doneButtonDidTap() {
    self.dismiss(animated: true)
  }
}


extension CarteViewController {
  open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.items.count
  }

  open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let item = self.items[indexPath.row]
    cell.textLabel?.text = item.displayName
    cell.detailTextLabel?.text = item.licenseName
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let carteItem = self.items[indexPath.row]
    let detailViewController = CarteDetailViewController(item: carteItem)
    self.configureDetailViewController?(detailViewController)
    self.navigationController?.pushViewController(detailViewController, animated: true)
  }
}


open class CarteDetailViewController: UIViewController {
  public let carteItem: CarteItem

  open var textView: UITextView = {
    let textView = UITextView()
    textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    textView.font = UIFont.preferredFont(forTextStyle: .footnote)
    textView.isEditable = false
    textView.alwaysBounceVertical = true
    textView.dataDetectorTypes = .link
    return textView
  }()

  public init(item: CarteItem) {
    self.carteItem = item
    super.init(nibName: nil, bundle: nil)
    self.title = item.displayName
    self.textView.text = item.licenseText
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func viewDidLoad() {
    self.view.backgroundColor = UIColor.white
    self.textView.frame = self.view.bounds
    self.textView.contentOffset = .zero
    self.view.addSubview(self.textView)
  }
}
#endif
