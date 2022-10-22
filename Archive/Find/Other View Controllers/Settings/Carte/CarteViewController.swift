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
        title = NSLocalizedString("Open Source Licenses", comment: "Open Source Licenses")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItemIfNeeded()
    }

    private func adjustLeftBarButtonItemIfNeeded() {
        guard navigationItem.leftBarButtonItem == nil else { return }

        let isPresented = (presentingViewController != nil)
        if isPresented {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(doneButtonDidTap)
            )
        }
    }

    @objc open dynamic func doneButtonDidTap() {
        dismiss(animated: true)
    }
}

extension CarteViewController {
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.displayName
        cell.detailTextLabel?.text = item.licenseName
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let carteItem = items[indexPath.row]
        let detailViewController = CarteDetailViewController(item: carteItem)
        configureDetailViewController?(detailViewController)
        navigationController?.pushViewController(detailViewController, animated: true)
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
        carteItem = item
        super.init(nibName: nil, bundle: nil)
        title = item.displayName
        textView.text = item.licenseText
    }
  
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        view.backgroundColor = UIColor.white
        textView.frame = view.bounds
        textView.contentOffset = .zero
        view.addSubview(textView)
    }
}
#endif
