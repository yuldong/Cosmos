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

public class InfoPanel : CanvasController {
    
    var link: TextShape?
    public override func setup() {
        canvas.backgroundColor = Color(red: 0, green: 0, blue: 0, alpha: 0.33)
        self.canvas.opacity = 0.0
        createLogo()
        createLabel()
        createLink()
        linkGesture()
        hideGesture()
    }
    
    func createLogo() -> Void {
        let logo = Image.init("logo")!
        logo.center = Point(canvas.center.x, canvas.height / 6.0)
        canvas.add(subview: logo)
    }
    
    func createLabel() {
        let message = "COSMOS is a lovingly\nbuilt app created\nby the C4 team.\n\n\nWe hope you enjoy\ncruising the COSMOS.\n\n\nYou can learn how\nto build this app\n on our site at:"
        let text = UILabel()
        text.font = UIFont(name: "Menlo-Regular", size: 18)
        text.numberOfLines = 40
        text.text = message
        text.textColor = UIColor.white
        text.textAlignment = .center
        text.sizeToFit()
        text.center = CGPoint.init(canvas.center)
        
        canvas.add(subview: text)
    }
    
    func createLink() {
        let text = TextShape(text: "www.c4ios.com", font: Font(name: "Menlo-Regular", size: 24)!)!
        text.fillColor = white
        text.center = Point(canvas.center.x, canvas.height * 5.0 / 6.0)
        
        let a = Point(text.origin.x, text.frame.max.y + 8)
        let b = Point(a.x + text.width + 1, a.y)
        
        let line = Line((a, b))
        line.lineWidth = 1.0
        line.strokeColor = C4Pink
        
        link = text
        canvas.add(subview: link)
        canvas.add(subview: line)
        
    }
    
    func linkGesture() {
        let press = link?.addLongPressGestureRecognizer(action: { (locations, center, state) in
            switch state {
            case .began, .changed:
                self.link?.fillColor = C4Pink
            case .ended:
                if let l = self.link, l.hitTest(point: center) {
                    UIApplication.shared.open(URL(string: "http://http://www.c4ios.com/cosmos/")!, options: [:], completionHandler: nil)
                }
                fallthrough
            default:
                self.link?.fillColor = white
            }
        })
        press?.minimumPressDuration = 0.0
    }
    
    func hideGesture() {
        canvas.addTapGestureRecognizer { (locations, center, state) in
            self.hide()
        }
    }
    
    func hide() -> Void {
        ViewAnimation(duration: 0.25) {
            self.canvas.opacity = 0.0
        }.animate()
    }
    
    func show() -> Void {
        ViewAnimation(duration: 0.25) {
            self.canvas.opacity = 1.0
        }.animate()
    }
}
