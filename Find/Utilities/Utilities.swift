//
//  BasicUtilities.swift
//  Find
//
//  Created by Andrew on 10/20/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import VideoToolbox
import UIKit
import SwiftUI
import SnapKit

var screenBounds: CGRect {
    get {
        return UIScreen.main.bounds
    }
}

extension CVPixelBuffer {
    
    /// Returns a Core Graphics image from the pixel buffer's current contents.
    func toCGImage() -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        
        if cgImage == nil { print("Error: Converting CVPixelBuffer to CGImage failed.") }
        return cgImage
    }
}

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}

extension NSLayoutConstraint {
//debug constraints
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
class ReceiveTouchView: UIView {
    
}
class PassthroughView: UIView {
    var passthroughActive = true
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        if passthroughActive {
            
            return subviews.contains(where: {
                ($0 is ReceiveTouchView && $0.point(inside: self.convert(point, to: $0), with: event)) || (
                    !$0.isHidden
                        && $0.isUserInteractionEnabled
                        && $0.point(inside: self.convert(point, to: $0), with: event)
                )
            })
        } else {
            print("Bounds: \(bounds), point: \(point), contains: \(self.bounds.contains(point))")
            return self.bounds.contains(point)
        }
    }
}


extension UISpringTimingParameters {
    
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
    
}
extension UIViewController {
    func addChild(_ childViewController: UIViewController, in inView: UIView) {
        // Add Child View Controller
        addChild(childViewController)
        
        // Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        // Configure Child View
        childViewController.view.frame = inView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    func removeChild(_ childViewController: UIViewController) {
        // Notify Child View Controller
        childViewController.willMove(toParent: nil)

        // Remove Child View From Superview
        childViewController.view.removeFromSuperview()

        // Notify Child View Controller
        childViewController.removeFromParent()
    }
}

infix operator >!<

func >!< (object1: AnyObject!, object2: AnyObject!) -> Bool {
   return (object_getClassName(object1) == object_getClassName(object2))
}

extension Array where Element: UIColor {
    func intermediate(percentage: CGFloat) -> UIColor {
        let percentage = Swift.max(Swift.min(percentage, 100), 0)
        switch percentage {
        case 0: return first ?? .clear
        case 1: return last ?? .clear
        default:
            let approxIndex = percentage / (1 / CGFloat(count - 1))
            let firstIndex = Swift.min(count - 1, Int(approxIndex.rounded(.down)))
            let secondIndex = Swift.min(count - 1, Int(approxIndex.rounded(.up)))
            let fallbackIndex = Swift.min(count - 1, Int(approxIndex.rounded()))

            let firstColor = self[firstIndex]
            let secondColor = self[secondIndex]
            let fallbackColor = self[fallbackIndex]

            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return fallbackColor }
            guard secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return fallbackColor }

            let intermediatePercentage = approxIndex - CGFloat(firstIndex)
            return UIColor(red: CGFloat(r1 + (r2 - r1) * intermediatePercentage),
                           green: CGFloat(g1 + (g2 - g1) * intermediatePercentage),
                           blue: CGFloat(b1 + (b2 - b1) * intermediatePercentage),
                           alpha: CGFloat(a1 + (a2 - a1) * intermediatePercentage))
        }
    }
}

extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

class PaddedLabel: UILabel {

    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var leftInset: CGFloat = 10
    var rightInset: CGFloat = 10

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

extension Date {
    func convertDateToReadableString() -> String {
        
        let todayLoc = NSLocalizedString("todayLoc", comment: "extensionDate def=Today")
        let yesterdayLoc = NSLocalizedString("yesterdayLoc", comment: "extensionDate def=Yesterday")
        
        
        
        /// Initializing a Date object will always return the current date (including time)
        let todaysDate = Date()
        
        guard let yesterday = todaysDate.subtract(days: 1) else { return "2020"}
        
        guard let oneWeekAgo = todaysDate.subtract(days: 7) else { return "2020"}
        guard let yestYesterday = yesterday.subtract(days: 1) else { return "2020"}
        
        /// This will be any date from one week ago to the day before yesterday
        let recently = oneWeekAgo...yestYesterday
        
        /// convert the date into a string, if the date is before yesterday
        let dateFormatter = DateFormatter()
        
        /// If self (the date that you're comparing) is today
        if self.hasSame(.day, as: todaysDate) {
            return todayLoc
            
            /// if self is yesterday
        } else if self.hasSame(.day, as: yesterday) {
            return yesterdayLoc
            
            /// if self is in between one week ago and the day before yesterday
        } else if recently.contains(self) {
            
            /// "EEEE" will display something like "Wednesday" (the weekday)
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: self)
            
            /// self is before one week ago
        } else {
            
            /// displays the date as "January 1, 2020"
            /// the ' ' marks indicate a character that you add (in our case, a comma)
            dateFormatter.dateFormat = "MMMM d"
            return dateFormatter.string(from: self)
        }
        
    }
    
    /// Thanks to Vasily Bodnarchuk: https://stackoverflow.com/a/40654331
    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
    
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        return self.compare(with: date, only: component) == 0
    }
    
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let comp = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: comp, to: self)
    }
    
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
}

class CellShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

// concatenate attributed strings
func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension UIView {
    var safeArea: ConstraintBasicAttributesDSL {
        
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                return self.safeAreaLayoutGuide.snp
            }
            return self.snp
        #else
            return self.snp
        #endif
    }
}
class GradientBorderView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        let inset = lineWidth / 2
        shapeLayer?.path = UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)), cornerRadius: cornerRadius).cgPath
    }

    var cornerRadius = CGFloat(3) {
        didSet {
            
            let inset = lineWidth / 2
            shapeLayer?.path = UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)), cornerRadius: cornerRadius).cgPath
            
            layer.cornerRadius = cornerRadius
        }
    }
    var colors = [CGColor]() {
        didSet {
            gradientLayer.colors = colors
        }
    }
    var lineWidth = CGFloat(3) {
        didSet {
            shapeLayer?.lineWidth = lineWidth
            
            let inset = lineWidth / 2
            gradientLayer.frame = self.bounds.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
        }
    }
    
    var shapeLayer: CAShapeLayer?
    lazy var gradientLayer: CAGradientLayer = {
        let inset = lineWidth / 2
        
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [#colorLiteral(red: 0.117850464, green: 0.6410203502, blue: 0.9803485577, alpha: 1).cgColor, #colorLiteral(red: 0.2087231564, green: 0.6273328993, blue: 0.8017540564, alpha: 1).cgColor]
        l.startPoint = CGPoint(x: 0.5, y: 0)
        l.endPoint = CGPoint(x: 0.5, y: 1)
        l.cornerRadius = cornerRadius
        layer.addSublayer(l)
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)), cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        l.mask = shape
        
        self.shapeLayer = shape
        
        shape.masksToBounds = false
        l.masksToBounds = false
        layer.masksToBounds = false
        
        layer.cornerRadius = cornerRadius
        return l
    }()
}

extension CALayer {
    func moveTo(point: CGPoint, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = value(forKey: "position")
            animation.toValue = NSValue(cgPoint: point)
            animation.fillMode = .forwards
            self.position = point
            add(animation, forKey: "position")
        } else {
            self.position = point
        }
    }

    func resize(to size: CGSize, animated: Bool) {
        let oldBounds = bounds
        var newBounds = oldBounds
        newBounds.size = size

        if animated {
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.fromValue = NSValue(cgRect: oldBounds)
            animation.toValue = NSValue(cgRect: newBounds)
            animation.fillMode = .forwards
            self.bounds = newBounds
            add(animation, forKey: "bounds")
        } else {
            self.bounds = newBounds
        }
    }

    func resizeAndMove(frame: CGRect, animated: Bool, duration: TimeInterval = 0) {
        if animated {
            let positionAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = value(forKey: "position")
            positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: frame.midX, y: frame.midY))

            let oldBounds = bounds
            var newBounds = oldBounds
            newBounds.size = frame.size

            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue(cgRect: oldBounds)
            boundsAnimation.toValue = NSValue(cgRect: newBounds)

            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [positionAnimation, boundsAnimation]
            groupAnimation.fillMode = .forwards
            groupAnimation.duration = duration
            groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.frame = frame
            add(groupAnimation, forKey: "frame")

        } else {
            self.frame = frame
        }
    }
}

//
//class GradientView: UIView {
//    var colors:     [CGColor] = [UIColor.blue.cgColor] { didSet { updateColors() }}
//    var startLocation: Double =   0.05 { didSet { updateLocations() }}
//    var endLocation:   Double =   0.95 { didSet { updateLocations() }}
//    var horizontalMode:  Bool =  false { didSet { updatePoints() }}
//    var diagonalMode:    Bool =  false { didSet { updatePoints() }}
//
//    override class var layerClass: AnyClass { CAGradientLayer.self }
//
//    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
//
//    func updatePoints() {
//        if horizontalMode {
//            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
//            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
//        } else {
//            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
//            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
//        }
//    }
//    func updateLocations() {
//        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
//    }
//    func updateColors() {
//        gradientLayer.colors = colors
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        updatePoints()
//        updateLocations()
//        updateColors()
//    }
//
//}
