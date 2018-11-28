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

//three colors we'll use throughout the app, so we make them project-level variables
let cosmosprpl = Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
let cosmosblue = Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
let cosmosbkgd = Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)

class WorkSpace: CanvasController {
    let infiniteScrollView = InfiniteScrollView()
    override func setup() {
        //work your magic here
        infiniteScrollView.frame = CGRect(canvas.frame)
        canvas.add(subview: infiniteScrollView)
        addVisualIndicators()
    }
    
    func addVisualIndicators() -> Void {
        let count = 20
        let gap = 150.0
        let dx = 40.0
        let width = Double(count + 1) * gap  + dx
        for x in 0...count {
            let point = Point(Double(x) * gap + dx, canvas.center.y)
            createIndicator(text: "\(x)", at: point)
        }
        
        var x: Int = 0
        var offset = dx
        while offset < Double(infiniteScrollView.frame.size.width) {
            let point = Point(width + offset, canvas.center.y)
            createIndicator(text: "\(x)", at: point)
            offset += gap
            x += 1
        }
        
        infiniteScrollView.contentSize = CGSize.init(width: CGFloat(CGFloat(width) + infiniteScrollView.frame.size.width), height: 0)
    }
    
    func createIndicator(text: String, at point: Point) -> Void {
        let ts = TextShape(text: text)
        ts?.center = point
        infiniteScrollView.add(subview: ts)
    }
    
    
}
