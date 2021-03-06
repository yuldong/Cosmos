// Copyright © 2016 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import QuartzCore
import UIKit

/// Shape is a concrete subclass of View that draws a bezier path in its coordinate space.
public class Shape: View {
    internal class ShapeView: UIView {
        var shapeLayer: ShapeLayer {
            return self.layer as! ShapeLayer // swiftlint:disable:this force_cast
        }
        
        override class var layerClass: AnyClass {
            get {
                return ShapeLayer.self
            }
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if shapeLayer.path!.contains(point, using: .winding) {
                return self
            }
            return nil
        }
    }

    /// C4Shape's contents are drawn on a ShapeLayer.
    public var shapeLayer: ShapeLayer {
        get {
            return self.shapeView.shapeLayer
        }
    }

    internal var shapeView: ShapeView {
        return self.view as! ShapeView // swiftlint:disable:this force_cast
    }

    ///  Initializes an empty Shape.
    public override init() {
        super.init()
        self.view = ShapeView(frame: CGRect(frame))
        strokeColor = C4Purple
        fillColor = C4Blue
        lineWidth = 1
        lineCap = .Round
        lineJoin = .Round

        let image = UIImage.createWithColor(color: UIColor.clear, size: CGSize(width: 1, height: 1)).cgImage
        shapeLayer.contents = image
    }

    /// Initializes a new Shape from a specified Path.
    /// - parameter path: A Path around which the new shape is created with the frame of the new shape fitting the path on
    /// screen.
    public convenience init(_ path: Path) {
        self.init()

        self.path = path
        shapeLayer.path = path.CGPath

        updatePath()
        adjustToFitPath()
    }

    public override init(frame: Rect) {
        super.init()
        self.view = ShapeView(frame: CGRect(frame))
        strokeColor = C4Purple
        fillColor = C4Blue
        lineWidth = 1
        lineCap = .Round
        lineJoin = .Round

        let image = UIImage.createWithColor(color: UIColor.clear, size: CGSize(width: 1, height: 1)).cgImage
        shapeLayer.contents = image
    }

    /// Initializes a new Shape from the properties of another Shape. Essentially, this copies the provided shape.
    /// - parameter shape: A Shape around which the new shape is created.
    public convenience init(copy original: Shape) {
        //If there is a scale transform we need to undo that
        let t = original.view.transform.inverted()
        let x = sqrt(t.a * t.a + t.c * t.c)
        let y = sqrt(t.b * t.b + t.d * t.d)
        let s = CGAffineTransform(scaleX: x, y: y)
        self.init(frame: Rect(original.view.frame.applying(s)))

        let disable = ShapeLayer.disableActions
        ShapeLayer.disableActions = true
        self.path = original.path
        shapeLayer.path = path?.CGPath
        self.lineWidth = original.lineWidth
        self.lineDashPhase = original.lineDashPhase
        self.lineCap = original.lineCap
        self.lineJoin = original.lineJoin
        self.lineDashPattern = original.lineDashPattern
        self.fillColor = original.fillColor
        self.strokeColor = original.strokeColor
        self.strokeStart = original.strokeStart
        self.strokeEnd = original.strokeEnd
        self.miterLimit = original.miterLimit
        updatePath()
        adjustToFitPath()
        copyViewStyle(viewToCopy: original)
        ShapeLayer.disableActions = disable
    }

    ///An optional variable representing a gradient. If this is non-nil, then the shape will appear to be filled with a gradient.
    public var gradientFill: Gradient? {
        didSet {
            guard gradientFill != nil else {
                fillColor = clear
                return
            }
            let gim = gradientFill?.render()?.cgimage

            //inverts coordinate for graphics context rendering
            var b = bounds
            b.origin.y = self.height - b.origin.y

            UIGraphicsBeginImageContextWithOptions(CGSize(b.size), false, UIScreen.main.scale)
            let context = UIGraphicsGetCurrentContext()
            context!.draw(gim!, in: CGRect(b), byTiling: true)
            let uiimage = UIGraphicsGetImageFromCurrentImageContext()
            let uicolor = UIColor(patternImage: uiimage!)
            fillColor = Color(uicolor)
            UIGraphicsEndImageContext()
        }
    }

    /// The path defining the shape to be rendered. If the path extends outside the layer bounds it will not automatically
    /// be clipped to the layer. Defaults to nil. Animatable.
    public var path: Path? {
        didSet {
            shapeLayer.path = path?.CGPath
        }
    }

    internal func updatePath() {}

    /// Adjusts the shape's frame to the bounding bounding box of its specified path.
    public func adjustToFitPath() {
        if shapeLayer.path == nil {
            return
        }
        view.bounds = shapeLayer.path!.boundingBox
        view.frame = view.bounds
    }


    /// Returns the receiver's frame. Animatable.
    public override var frame: Rect {
        get {
            return Rect(view.frame)
        }
        set {
            view.frame = CGRect(newValue)
            updatePath()
        }
    }

    /// The line width used when stroking the path. Defaults to 1.0. Animatable.
    @IBInspectable
    public var lineWidth: Double {
        get { return Double(shapeLayer.lineWidth) }
        set(width) { shapeLayer.lineWidth = CGFloat(width) }
    }

    /// The color to stroke the path, or nil for no fill. Defaults to opaque black. Animatable.
    public var strokeColor: Color? {
        get {
            if let color = shapeLayer.strokeColor {
                return Color(color)
            } else {
                return nil
            }
        }
        set(color) {
            shapeLayer.strokeColor = color?.color
        }
    }

    /// The color to fill the path, or nil for no fill. Defaults to opaque black. Animatable.
    public var fillColor: Color? {
        get {
            if let color = shapeLayer.fillColor {
                return Color(color)
            } else {
                return nil
            }
        }
        set(color) {
            shapeLayer.fillColor = color?.color
        }
    }

    /// The fill rule used when filling the path. Defaults to `NonZero`.
    public var fillRule: FillRule {
        get {
            switch shapeLayer.fillRule {
            case CAShapeLayerFillRule.nonZero:
                return .NonZero
            case CAShapeLayerFillRule.evenOdd:
                return .EvenOdd
            default:
                return .NonZero
            }
        }
        set(fillRule) {
            switch fillRule {
            case .NonZero:
                shapeLayer.fillRule = CAShapeLayerFillRule.nonZero
            case .EvenOdd:
                shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
            }
        }
    }

    /// The current rotation value of the view. Animatable.
    /// - returns: A Double value representing the cumulative rotation of the view, measured in Radians.
    public override var rotation: Double {
        get {
            if let number = shapeLayer.value(forKeyPath: Layer.rotationKey) as? NSNumber {
                return number.doubleValue
            }
            return  0.0
        }
        set {
            shapeLayer.setValue(newValue, forKeyPath: Layer.rotationKey)
        }
    }

    /// This value defines the start of the path used to draw the stroked outline. The value must be in the range [0,1]
    /// with zero representing the start of the path and one the end. Values in between zero and one are interpolated
    /// linearly along the path length. Defaults to zero. Animatable.
    public var strokeStart: Double {
        get { return Double(shapeLayer.strokeStart) }
        set(start) { shapeLayer.strokeStart = CGFloat(start) }
    }

    /// This value defines the end of the path used to draw the stroked outline. The value must be in the range [0,1]
    /// with zero representing the start of the path and one the end. Values in between zero and one are interpolated
    /// linearly along the path length. Defaults to 1.0. Animatable.
    public var strokeEnd: Double {
        get { return Double(shapeLayer.strokeEnd) }
        set(end) { shapeLayer.strokeEnd = CGFloat(end) }
    }

    /// The miter limit used when stroking the path. Defaults to ten. Animatable.
    @IBInspectable
    public var miterLimit: Double {
        get { return Double(shapeLayer.miterLimit) }
        set(miterLimit) { shapeLayer.miterLimit = CGFloat(miterLimit) }
    }

    /// The cap style used when stroking the path. Defaults to `Butt`.
    public var lineCap: LineCap {
        get {
            switch shapeLayer.lineCap {
            case CAShapeLayerLineCap.butt:
                return .Butt
            case CAShapeLayerLineCap.round:
                return .Round
            case CAShapeLayerLineCap.square:
                return .Square
            default:
                return .Butt
            }
        }
        set(lineCap) {
            switch lineCap {
            case .Butt:
                shapeLayer.lineCap = CAShapeLayerLineCap.butt
            case .Round:
                shapeLayer.lineCap = CAShapeLayerLineCap.round
            case .Square:
                shapeLayer.lineCap = CAShapeLayerLineCap.square
            }
        }
    }

    /// The join style used when stroking the path. Defaults to `Miter`.
    public var lineJoin: LineJoin {
        get {
            switch shapeLayer.lineJoin {
            case CAShapeLayerLineJoin.miter:
                return .Miter
            case CAShapeLayerLineJoin.round:
                return .Round
            case CAShapeLayerLineJoin.bevel:
                return .Bevel
            default:
                return .Miter
            }
        }
        set(lineJoin) {
            switch lineJoin {
            case .Miter:
                shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
            case .Round:
                shapeLayer.lineJoin = CAShapeLayerLineJoin.round
            case .Bevel:
                shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel
            }
        }
    }

    /// The phase of the dashing pattern applied when creating the stroke. Defaults to zero. Animatable.
    public var lineDashPhase: Double {
        get { return Double(shapeLayer.lineDashPhase) }
        set(phase) { shapeLayer.lineDashPhase = CGFloat(phase) }
    }


    /// The dash pattern applied when creating the stroked version of the path. Defaults to nil.
    public var lineDashPattern: [NSNumber]? {
        get { return shapeLayer.lineDashPattern as [NSNumber]? }
        set(pattern) { shapeLayer.lineDashPattern = pattern }
    }

    /// The size of the receiver including the width of its stroke.
    /// - returns: The bounding box that surrounds the shape and its line.
    public func intrinsicContentSize() -> CGSize {
        if let path = path {
            let boundingBox = path.boundingBox()
            return CGSize(width: boundingBox.max.x + lineWidth/2, height: boundingBox.max.y + lineWidth/2)
        } else {
            return CGSize()
        }
    }
    
    /// Creates a flattened image of the receiver and its subviews / layers.
    /// This override takes into consideration the lineWidth of the receiver.
    /// - returns: A new Image
    public override func render() -> Image? {
        var s = CGSize(size)
        var inset: CGFloat = 0
        if lineWidth > 0, let sc = strokeColor, sc.alpha > 0.0 {
            inset = CGFloat(lineWidth / 2.0)
            s = CGRect(frame).insetBy(dx: -inset, dy: -inset).size
        }
        
        let scale = CGFloat(UIScreen.main.scale)
        UIGraphicsBeginImageContextWithOptions(s, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: CGFloat(-bounds.origin.x)+inset, y: CGFloat(-bounds.origin.y)+inset)
        shapeLayer.render(in: context)
        let uiimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image(uiimage: uiimage!)
    }

    /// Returns true if there is no path.
    public func isEmpty() -> Bool {
        return path == nil || path!.isEmpty()
    }


    /// The join style for joints on the shape's path.
    public enum LineJoin {
        /// Specifies a miter line shape of the joints between connected segments of a stroked path.
        case Miter

        /// Specifies a round line shape of the joints between connected segments of a stroked path.
        case Round

        /// Specifies a bevel line shape of the joints between connected segments of a stroked path.
        case Bevel
    }


    /// The cap style for the ends of the shape's path.
    public enum LineCap {
        /// Specifies a butt line cap style for endpoints for an open path when stroked.
        case Butt

        /// Specifies a round line cap style for endpoints for an open path when stroked.
        case Round

        /// Specifies a square line cap style for endpoints for an open path when stroked.
        case Square
    }

    public override func hitTest(point: Point) -> Bool {
        if let p = path {
            return p.containsPoint(point: point)
        }
        return false
    }
}
