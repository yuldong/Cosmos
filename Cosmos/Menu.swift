// Copyright © 2015 
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

typealias SelectionAction = (_ selection: Int) -> Void

typealias InfoAction = () -> Void

class Menu : CanvasController {
    
    var menuRings: MenuRings?
    var menuIcons: MenuIcons?
    var menuSelector: MenuSelector?
    var menuShadow: MenuShadow?
    var shouldRevert = false
    
    var menuIsVisible = false
    
    let hideMenuSound = AudioPlayer("menuClose.mp3")!
    let revealMenuSound = AudioPlayer("menuOpen.mp3")!
    
    var instructionLabel: UILabel!
    
    var timer: C4Timer!
    
    var selectionAction: SelectionAction?
    
    var infoAction: InfoAction?
    
    override func setup() {
        canvas.backgroundColor = clear
        canvas.frame  = Rect(0, 0, 80, 80)
        createGesture()
        menuRings = MenuRings()
        menuIcons = MenuIcons()
        menuSelector = MenuSelector()
        menuShadow = MenuShadow()
        menuShadow?.canvas.center = canvas.bounds.center
        
        canvas.add(subview: menuShadow?.canvas)
        canvas.add(subview: menuRings?.canvas)
        canvas.add(subview: menuSelector?.canvas)
        canvas.add(subview: menuIcons?.canvas)
        
        createInstructionLabel()
        timer = C4Timer(interval: 5.0, count: 1, action: {
            self.showInstruction()
        })
        timer.start()
        
        hideMenuSound.volume = 0.64
        revealMenuSound.volume = 0.64
    }
    
    func createGesture() {
        canvas.addLongPressGestureRecognizer { (locations, center, state) in
            switch state {
            case .began:
                self.revealMenu()
            case .changed:
                self.menuSelector?.update(location: center)
            case .cancelled, .ended, .failed:
                if let sa = self.selectionAction, self.menuSelector!.currentSelection >= 0 {
                    sa((self.menuSelector?.currentSelection)!)
                }
                if let ib = self.menuSelector?.infoButton {
                    if ib.hitTest(point: center, from: self.canvas), let ia = self.infoAction {
                        wait(seconds: 1.0) {
                            ia()
                        }
                    }
                }
                self.canvas.interactionEnabled = false
                if self.menuIsVisible {
                    self.hideMenu()
                } else {
                    self.shouldRevert = true
                }
                self.menuSelector?.currentSelection = -1
                self.menuSelector?.highlight.hidden = true
                self.menuSelector?.menuLabel.hidden = true
            default:
                _ = ""
            }
        }
    }
    
    func revealMenu() -> Void {
        if instructionLabel.alpha > 0.0 {
            hideInstruction()
        }
        revealMenuSound.play()
        menuIsVisible = false
        menuShadow?.reveal?.animate()
        menuRings?.thickRingOut?.animate()
        menuRings?.thinRingsOut?.animate()
        menuIcons?.signIconsOut.animate()
        
        wait(seconds: 0.33) {
//            self.menuRings.revealHideDividingLines(target: 1.0)
            self.menuIcons?.revealSignIcons.animate()
        }
        
        wait(seconds: 0.66) {
            self.menuRings?.revealDashedRings?.animate()
            self.menuSelector?.revealInfoButton?.animate()
            self.canvas.interactionEnabled = true
        }
        wait(seconds: 1.0) {
            self.menuIsVisible = true
            if self.shouldRevert {
                self.hideMenu()
                self.menuIsVisible = true
            }
        }
    }
    
    func hideMenu() -> Void {
        hideMenuSound.play()
        self.menuIsVisible = false
        menuRings?.hideDashedRings?.animate()
        menuSelector?.hideInfoButton?.animate()
//        menuRings.revealHideDividingLines(target: 0.0)
        
        wait(seconds: 0.16) {
            self.menuIcons?.hideSignIcons.animate()
        }
        wait(seconds: 0.57) {
            self.menuRings?.thinRingsIn?.animate()
        }
        wait(seconds: 0.66) {
            self.menuIcons?.signIconsIn.animate()
            self.menuRings?.thickRingIn?.animate()
            self.menuShadow?.hide?.animate()
            self.canvas.interactionEnabled = true
        }
    }
    
    func createInstructionLabel() -> Void {
        instructionLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: 320, height: 44))
        instructionLabel.text = "press and hold to open menu\nthen drag to choose a sign"
        instructionLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = UIColor.white
        instructionLabel.isUserInteractionEnabled = false
        instructionLabel.center = CGPoint.init(x: view.center.x, y: view.center.y - 128)
        instructionLabel.numberOfLines = 2
        instructionLabel.alpha = 0.0
        canvas.add(subview: instructionLabel)
    }
    
    func showInstruction() {
        ViewAnimation(duration: 2.5) {
            self.instructionLabel.alpha = 1.0
        }.animate()
    }
    
    func hideInstruction() -> Void {
        ViewAnimation(duration: 0.25) {
            self.instructionLabel.alpha = 0.0
        }.animate()
    }
}
