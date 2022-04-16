////
////  TextEntity.swift
////  Find
////
////  Created by A. Zheng (github.com/aheze) on 4/16/22.
////  Copyright © 2022 A. Zheng. All rights reserved.
////
//    
//import RealityKit
//import UIKit
//
///// from https://github.com/Reality-Dev/RealityKit-Text
//@available(iOS 13.0, *)
//open class TextEntity: Entity {
//    public var text: String = "Hello World" {
//        didSet { if oldValue != text { makeText() }}
//    }
//
//    public var color: UIColor = .blue {
//        didSet { if oldValue != color { makeText() }}
//    }
//
//    public var isLit: Bool = true {
//        didSet { if oldValue != isLit { makeText() }}
//    }
//
//    public var size: CGFloat = 0.1 {
//        didSet { if oldValue != size { makeText() }}
//    }
//
//    public var isMetallic: Bool = true {
//        didSet { if oldValue != isMetallic { makeText() }}
//    }
//
//    public var fontName: String = "Helvetica" {
//        didSet { if oldValue != fontName { makeText() }}
//    }
//
//    public var extrusionDepth: Float = 0.01 {
//        didSet { if oldValue != extrusionDepth { makeText() }}
//    }
//
////    public var alignment: CTTextAlignment = .center {
////        didSet { if oldValue != alignment { makeText() }}
////    }
//    
//    /// The child of the TextEntity, which has the visible mesh and material.
//    ///
//    /// The textModel has its position compensated relative to its parent (the TextEntity) to make it have the proper alignment.
//    private var textModel: ModelEntity!
//    
//    public enum alignment {
//        case left, center, right
//    }
//
//    public required init() {
//        super.init()
//        makeText()
//    }
//    
//    public init(text: String = "Hello World", color: UIColor = .blue) {
//        super.init()
//        self.text = text
//        self.color = color
//        makeText(text: text, color: color)
//    }
//    
//    public init(text: String = "Hello World", color: UIColor = .blue, isLit: Bool = true, size: CGFloat = 0.1, isMetallic: Bool = true, fontName: String = "Helvetica", extrusionDepth: Float = 0.01) {
//        super.init()
//        self.text = text
//        self.color = color
//        self.isLit = isLit
//        self.size = size
//        self.isMetallic = isMetallic
//        self.fontName = fontName
//        self.extrusionDepth = extrusionDepth
//        makeText(text: text, color: color, isLit: isLit, size: size, isMetallic: isMetallic, fontName: fontName, extrusionDepth: extrusionDepth, alignment: alignment)
//    }
//    
//    // Using nil default values allows us to not call makeText() for every variable's didSet{} property observer upon initialization.
//    private func makeText(text: String? = nil,
//                          color: UIColor? = nil,
//                          isLit: Bool? = nil,
//                          size: CGFloat? = nil,
//                          isMetallic: Bool? = nil,
//                          fontName: String? = nil,
//                          extrusionDepth: Float? = nil,
//                          alignment: alignment? = nil)
//    {
//        DispatchQueue.main.async {
//            let textLocal = text ?? self.text
//            let colorLocal = color ?? self.color
//            let isLitLocal = isLit ?? self.isLit
//            let sizeLocal = size ?? self.size
//            let isMetalliclocal = isMetallic ?? self.isMetallic
//            let fontNameLocal = fontName ?? self.fontName
//            let extrustionDepthLocal = extrusionDepth ?? self.extrusionDepth
//        
//            let textMesh = MeshResource.generateText(textLocal,
//                                                     extrusionDepth: extrustionDepthLocal,
//                                                     font: UIFont(name: fontNameLocal, size: sizeLocal)!,
//                                                     containerFrame: CGRect.zero,
//                                                     alignment: .natural,
//                                                     lineBreakMode: .byTruncatingTail)
//            var textMaterial: Material
//            if isLitLocal {
//                textMaterial = SimpleMaterial(color: colorLocal, isMetallic: isMetalliclocal)
//            } else {
//                // Create an unlit material.
//                textMaterial = UnlitMaterial(color: colorLocal)
//            }
//
//            self.textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
//            self.textModel.name = "textModel"
//        
//            // removeAll(where:) is not available.
//            for child in self.children { if child.name == "textModel" { child.removeFromParent() } }
//            self.addChild(self.textModel)
//        
//            // Move it down and to the left relative to its parent entity by the magnitude of the compensation.
//            self.textModel.position = self.getCompensation(alignment: alignmentLocal)
//        }
//    }
//
//    /// Gets half of the width, height and length of the bounding box,
//    /// because the origin-point of the text is originally in the bottom-left corner of the bounding box.
//    private func getCompensation(alignment: alignment = .center) -> SIMD3<Float> {
//        let bounds = textModel.model?.mesh.bounds
//        let boxCenter = bounds!.center
//        let boxMin = bounds!.min
//        var compensation = boxMin - boxCenter
//        // was already in the center on the Z-Axis.
//        switch alignment {
//            case .center:
//                compensation *= [1, 1, 0]
//            case .left:
//                compensation *= [2, 1, 0]
//            case .right:
//                compensation *= [0, 1, 0]
//        }
//        return compensation
//    }
//}
