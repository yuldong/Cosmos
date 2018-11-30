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

var gapBetweenSigns: CGFloat = 10.0
class Stars : CanvasController, UIScrollViewDelegate {
    let speeds : [CGFloat] = [0.08, 0.0, 0.10, 0.12, 0.15, 1.0, 0.8, 1.0]
    var scrollviews: [InfiniteScrollView]!
    
    var scrollviewOffsetContext = 0
    
    var signLines : SignLines!
    var bigStars : StarsBig!
    
    var snapTargets : [CGFloat]!
    override func setup() {
        scrollviews = [InfiniteScrollView]()
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "0Star", starCount: 20, speed: speeds[0]))
        scrollviews.append(createVignette())
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "2Star", starCount: 20, speed: speeds[2]))
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "3Star", starCount: 20, speed: speeds[3]))
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "4Star", starCount: 20, speed: speeds[4]))

        signLines = SignLines(frame: view.frame)
        scrollviews.append(signLines)
        
        scrollviews.append(StarsSmall(frame: view.frame, speed: speeds[6]))
        
        bigStars = StarsBig(frame: view.frame)
        bigStars.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &scrollviewOffsetContext)
        bigStars.delegate = self;
        scrollviews.append(bigStars)
        
        for sv in scrollviews {
            canvas.add(subview: sv)
        }
        createSnapTargets()
    }
    
    func createVignette() -> InfiniteScrollView {
        let sv = InfiniteScrollView.init(frame: view.frame)
        let img = Image.init("1vignette")!
        img.frame = canvas.frame
        sv.add(subview: img)
        return sv
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &scrollviewOffsetContext {
            let sv = object as! InfiniteScrollView
            let offset = sv.contentOffset
            for i in 0..<scrollviews.count - 1 {
                let layer = scrollviews[i]
                layer.contentOffset = CGPoint.init(x: offset.x * speeds[i], y: 0.0)
            }
        }
    }
    
    func createSnapTargets() {
        snapTargets = [CGFloat]()
        for i in 0...12 {
            snapTargets.append(gapBetweenSigns * CGFloat(i) * view.frame.width)
        }
    }
    
    func snapIfNeed(x: CGFloat, _ scrollView: UIScrollView) {
        for target in snapTargets {
            let dist = abs(CGFloat(target) - x)
            if dist < CGFloat(canvas.width / 2.0) {
                scrollView.setContentOffset(CGPoint.init(x: target, y: 0), animated: true)
                wait(seconds: 0.25) {
                    self.signLines.revealCurrentSignLines()
                }
                return
            }
        }
    }
    
    func goto(selection: Int) {
        let target = canvas.width * Double(gapBetweenSigns) * Double(selection)
        
        let anim = ViewAnimation(duration: 3.0) {
            self.bigStars.contentOffset = CGPoint.init(x: CGFloat(target), y: 0)
        }
        anim.curve = .EaseOut
        anim.addCompletionObserver {
            self.signLines.revealCurrentSignLines()
        }
        anim.animate()
        signLines.currentIndex = selection
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapIfNeed(x: scrollView.contentOffset.x, scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            snapIfNeed(x: scrollView.contentOffset.x, scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.signLines.hideCurrentSignLines()
    }
}
