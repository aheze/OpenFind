//
//  Pip.swift
//  FluidInterfaces
//
//  Created by Nathan Gitter on 7/8/18.
//  Copyright © 2018 Nathan Gitter. All rights reserved.
//
import UIKit
import CoreGraphics


extension CGPoint {
    
    /// Calculates the distance between two points in 2D space.
    /// + returns: The distance from this point to the given point.
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
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
/// Base class for all interface view controllers.
//class InterfaceViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = UIColor(white: 0.05, alpha: 1) // reduces screen tearing on iPhone X
//        navigationItem.largeTitleDisplayMode = .never
//
//    }
//
//}
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255
        let g = CGFloat((hex & 0xFF00) >> 8) / 255
        let b = CGFloat((hex & 0xFF)) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
class MatchesGradientView: UIView {
    
    public var topColor: UIColor = .white {
        didSet {
            updateGradientColors()
        }
    }
    
    public var bottomColor: UIColor = .black {
        didSet {
            updateGradientColors()
        }
    }
    
    /// The corner radius of the view.
    /// If no value is provided, the default is 20% of the view's width.
    public var cornerRadius: CGFloat? {
        didSet {
            layoutSubviews()
        }
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius ?? bounds.width * 0.2).cgPath
        layer.mask = maskLayer
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
}
extension ViewController {
    
    @objc func pipPanned(recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            initialOffset = CGPoint(x: touchPoint.x - matchesBig.center.x, y: touchPoint.y - matchesBig.center.y)
            print("3")
        case .changed:
            print("1")
            matchesBig.center = CGPoint(x: touchPoint.x - initialOffset.x, y: touchPoint.y - initialOffset.y)
        case .ended, .cancelled:
            print("2")
            let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
            let velocity = recognizer.velocity(in: view)
            let projectedPosition = CGPoint(
                x: matchesBig.center.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
                y: matchesBig.center.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
            )
            let nearestCornerPosition = nearestCorner(to: projectedPosition)
            let relativeInitialVelocity = CGVector(
                dx: relativeVelocity(forVelocity: velocity.x, from: matchesBig.center.x, to: nearestCornerPosition.x),
                dy: relativeVelocity(forVelocity: velocity.y, from: matchesBig.center.y, to: nearestCornerPosition.y)
            )
            let timingParameters = UISpringTimingParameters(damping: 1, response: 0.4, initialVelocity: relativeInitialVelocity)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            animator.addAnimations {
                print("ended")
                self.matchesShouldFireTimer = false
                for view in self.pipPositionViews {
                    UIView.animate(withDuration: 0.2, animations: {
                        view.alpha = 0
                    }, completion: {
                        _ in
                        view.isHidden = true
                    })
                    
                }
                self.matchesBig.center = nearestCornerPosition
                self.currentPipPosition = nearestCornerPosition
            }
            animator.startAnimation()
        default:
            print("12")
            break
        }
    }
    func addPipPositionView() -> PipPositionView {
        let view = PipPositionView()
        self.view.addSubview(view)
        pipPositionViews.append(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: pipWidth).isActive = true
        view.heightAnchor.constraint(equalToConstant: pipHeight).isActive = true
        return view
    }
    func checkAction(sender : UITapGestureRecognizer) {
        print("tap")
    }
    func setUpMatches() {
        
        
        matchesBig.layer.cornerRadius = 16
    
        let horizontalSpacing: CGFloat = 23
        let midHorizontalSpacing: CGFloat = 25
        let verticalSpacing: CGFloat = 200
    
        let topLeftView = addPipPositionView()
        topLeftView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing).isActive = true
        topLeftView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing).isActive = true
        
        let topRightView = addPipPositionView()
        topRightView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing).isActive = true
        topRightView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing).isActive = true
        
        let midLeftView = addPipPositionView()
        midLeftView.leadingAnchor.constraint(equalTo: topLeftView.trailingAnchor, constant: midHorizontalSpacing).isActive = true
        midLeftView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing).isActive = true
        
        let midRightView = addPipPositionView()
        midRightView.trailingAnchor.constraint(equalTo: topRightView.leadingAnchor, constant: -midHorizontalSpacing).isActive = true
        midRightView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing).isActive = true
        
//        view.addSubview(matchesBig)
//        matchesBig.translatesAutoresizingMaskIntoConstraints = false
//        matchesBig.widthAnchor.constraint(equalToConstant: pipWidth).isActive = true
//        matchesBig.heightAnchor.constraint(equalToConstant: pipHeight).isActive = true
//
        panRecognizer.addTarget(self, action: #selector(pipPanned(recognizer:)))
        matchesBig.addGestureRecognizer(panRecognizer)
        
    }
    
    /// Distance traveled after decelerating to zero velocity at a constant rate.
    func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
    /// Finds the position of the nearest corner to the given point.
    func nearestCorner(to point: CGPoint) -> CGPoint {
        var minDistance = CGFloat.greatestFiniteMagnitude
        var closestPosition = CGPoint.zero
        for position in pipPositions {
            let distance = point.distance(to: position)
            if distance < minDistance {
                closestPosition = position
                minDistance = distance
            }
        }
        return closestPosition
    }
    
    /// Calculates the relative velocity needed for the initial velocity of the animation.
    func relativeVelocity(forVelocity velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0 else { return 0 }
        return velocity / (targetValue - currentValue)
    }

}

class PipPositionView: UIView {
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.lineWidth = lineWidth
        layer.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.1)
        return layer
    }()
    
    private let lineWidth: CGFloat = 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2), cornerRadius: 16).cgPath
    }
    
}
