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
    var layers = [InfiniteScrollView]()
    override func setup() {
        //work your magic here
        repeat {
            let layer = InfiniteScrollView.init(frame: view.frame)
            layer.contentSize = CGSize.init(width: layer.frame.size.width * 10, height: 0)
            canvas.add(subview: layer)
            layers.append(layer)
            
            canvas.backgroundColor = black
            let starCount = layers.count * 15
            for _ in 0..<starCount {
                let img = Image("6smallStar")!
                img.constrainsProportions = true
                img.width *= 0.1 * Double(layers.count + 1)
                img.center = Point(Double(layer.contentSize.width) * random01(), canvas.height * random01())
                layer.add(subview: img)
            }
            
//            var center = Point(24, canvas.height / 2.0)
//            let layNumber = 10 - layers.count
//            let font = Font(name: "AvenirNext-DemiBold", size: Double(layers.count + 1) * 8.0)!
//            repeat {
//                let label = TextShape(text: "\(layNumber)", font: font)!
//                label.center = center
//                center.x += 130
//                layer.add(subview: label)
//            } while center.x < Double(layer.contentSize.width)
        } while layers.count < 10
        
        if let top = layers.last {
            var c = 0
            top.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: &c)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        for i in 0..<layers.count - 1 {
            let layer = self.layers[i]
            let mod = 0.1 * CGFloat(i + 1)
            if let x = layers.last?.contentOffset.x {
                layer.contentOffset  = CGPoint.init(x: x*mod, y: 0.0)
            }
        }
    }
}
