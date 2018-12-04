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

public class SignLines : InfiniteScrollView {
    var lines: [[Line]]!
    var currentIndex: Int = 0
    var currentLines: [Line] {
        get {
            let set = lines[currentIndex]
            return set
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let count = CGFloat.init(AstrologicalSignProvider.sharedInstance.order.count)
        contentSize = CGSize.init(width: frame.width * (count * gapBetweenSigns + 1), height: 1.0)
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        signOrder.append(signOrder.first!)
        
        lines = [[Line]]()
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.width * gapBetweenSigns)
            let t = Transform.makeTranslation(translation: Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            if let sign = AstrologicalSignProvider.sharedInstance.get(sign: signOrder[i]) {
                let connections = sign.lines
                var currentLineSet = [Line]()
                for points in connections {
                    var begin = points[0]
                    begin.transform(t: t)
                    var end = points[1]
                    end.transform(t: t)
                    
                    let line = Line(begin: begin, end: end)
                    line.lineWidth = 1.0
                    line.strokeColor = C4Pink
                    line.opacity = 0.4
                    line.strokeEnd = 0.0
                    add(subview: line)
                    currentLineSet.append(line)
                }
                lines.append(currentLineSet)
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func revealCurrentSignLines() {
        ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 1.0
            }
        }.animate()
    }
    
    func hideCurrentSignLines() {
        ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 0.0
            }
        }.animate()
    }
}
