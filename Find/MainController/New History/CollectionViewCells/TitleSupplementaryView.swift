
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Simple example of a self-sizing supplementary title view
*/

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    
    @IBOutlet weak var todayLabel: UILabel! 
    
//    public let Style = DefaultStyle.self
//    var path: UIBezierPath!
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    override func draw(_ rect: CGRect) {
//        self.createRectangle()
//    }
//
//    func createRectangle() {
//        //print("frame: \(self.frame)")
//        print("RECT")
//        let arcRadius = CGFloat(4)
//        let width = self.frame.size.width
//        //print(self.frame.size.height)
//        //let height = self.frame.size.height + arcRadius
//        let height = CGFloat(self.frame.size.height)
//        let origin = CGPoint(x: 0, y: height + arcRadius)
//        //print(origin)
//
//        // Initialize the path.
//        path = UIBezierPath()
//
//        // Specify the point that the path should start get drawn.
//        path.move(to: origin)
//
//        //first arc
//        path.addArc(withCenter: CGPoint(x: arcRadius, y: height + arcRadius), radius: arcRadius, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
//
//        // Create a line between the end of the first arc and the start of the second
//        path.addLine(to: CGPoint(x: width - arcRadius, y: height))
//        path.addArc(withCenter: CGPoint(x: width - arcRadius, y: height + arcRadius), radius: arcRadius, startAngle: CGFloat(270).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
//
//        // Line from topmost right to bottom right
//        path.addLine(to: CGPoint(x: width, y: 0))
//
//        // Line from bottom right to bottom left
//        path.addLine(to: CGPoint(x: 0, y: 0))
//
//        // Close the path.
//        path.close()
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        shapeLayer.fillColor = UIColor(named: "Gray2")?.cgColor
//        self.layer.insertSublayer(shapeLayer, below: todayLabel.layer)
//    }
//    let label = UILabel()
//    static let reuseIdentifier = "title-supplementary-reuse-identifier"
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//    }
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
    
    
    
}

//extension TitleSupplementaryView {
//    func configure() {
//        addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.adjustsFontForContentSizeCategory = true
//        let inset = CGFloat(10)
//        NSLayoutConstraint.activate([
//            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
//            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
//            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
//            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
//        ])
//        label.font = UIFont.preferredFont(forTextStyle: .title3)
//    }
//}
