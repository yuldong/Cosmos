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

import UIKit

public class StarsBig : InfiniteScrollView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        contentSize = CGSize.init(width: frame.size.width * (1.0 + CGFloat(signOrder.count) * gapBetweenSigns), height: 1.0)
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.size.width  * gapBetweenSigns)
            let t = Transform.makeTranslation(translation: Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            if let sign = AstrologicalSignProvider.sharedInstance.get(sign: signOrder[i]) {
                for point in sign.big {
                    let img = Image("7bigStar")!
                    var p = point
                    p.transform(t: t)
                    img.center = p
                    add(subview: img)
                }
            }
        }
        
        addDashed()
        addMakers()
        addSignNames()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func addDashed() {
        let points = (Point(0,Double(frame.maxY)),Point(Double(contentSize.width),Double(frame.maxY)))
        let dashes = Line(points)
        dashes.lineDashPattern = [2, 2] as [NSNumber]
        dashes.lineWidth = 10
        dashes.strokeColor = cosmosblue
        dashes.opacity = 0.33
        dashes.lineCap = .Butt
        add(subview: dashes)
    }
    
    func addMakers() {
        for i in 0..<AstrologicalSignProvider.sharedInstance.order.count {
            let dx = Double(i) * Double(frame.width * gapBetweenSigns) + Double(frame.width / 2.0)
            let begin = Point(dx, Double(frame.height - 20.0))
            let end = Point(dx, Double(frame.height))
            
            let marker = Line(begin: begin, end: end)
            marker.lineWidth = 2
            marker.strokeColor = white
            marker.lineCap = .Butt
            marker.opacity = 0.33
            add(subview: marker)
        }
    }
    
    func addSignNames() {
        var signNames = AstrologicalSignProvider.sharedInstance.order
        signNames.append(signNames[0])
        
        let y = Double(frame.size.height - 86.0)
        let dx = Double(frame.size.width * gapBetweenSigns)
        let offset = Double(frame.size.width / 2.0)
        let font = Font(name:"Menlo-Regular", size: 13.0)!
        
        for i in 0..<signNames.count {
            // 对每个符号和标签设置位置
            let name = signNames[i]
            var point = Point(offset + dx * Double(i), y)
            if let sign = self.createSmallSign(name: name) {
                sign.center = point
                add(subview: sign)
            }
            point.y += 26.0
            
            let title = self.createSmallSignTitle(name: name, font: font)
            title.center = point
            point.y += 22.0
            
            var value = i * 30
            if value > 330 { value = 0 }
            let degree = self.createSmallSignDegree(degree: value, font: font)
            degree.center = point
            
            add(subview: title)
            add(subview: degree)
        }
    }

    func createSmallSign(name: String) -> Shape? {
        var smallSign : Shape?
        //try to extract a sign from the provider, and style it
        if let sign = AstrologicalSignProvider.sharedInstance.get(sign: name)?.shape {
            sign.lineWidth = 2
            sign.strokeColor = white
            sign.fillColor = clear
            sign.opacity = 0.33
            //scale the sign down from its original size
            sign.transform = Transform.makeScale(sx: 0.66, 0.66, 0)
            smallSign = sign
        }
        return smallSign
    }
    
    func createSmallSignTitle(name: String, font: Font) -> TextShape {
        let text = TextShape(text:name, font:font)!
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }
    
    func createSmallSignDegree(degree: Int, font: Font) -> TextShape {
        return createSmallSignTitle(name: "\(degree)°", font: font)
    }
}
