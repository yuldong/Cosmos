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

extension Image {
    ///  Applies a generator to the receiver's contents.
    ///
    ///  - parameter generator: a Generator
    public func generate(generator: Generator) {
        let crop = CIFilter(name: "CICrop")!
        crop.setDefaults()
        crop.setValue(CIVector(cgRect:CGRect(self.bounds)), forKey: "inputRectangle")
        let generatorFilter = generator.createCoreImageFilter()
        crop.setValue(generatorFilter.outputImage, forKey: "inputImage")

        if var outputImage = crop.outputImage {
            let scale = CGAffineTransform(scaleX: 1, y: -1)
            let translate = scale.translatedBy(x: 0, y: outputImage.extent.size.height)
            outputImage = outputImage.transformed(by: translate)
            self.output = outputImage

            let img = UIImage(ciImage: output)
            let orig = self.origin
            self.view = UIImageView(image: img)
            self.origin = orig
            _originalSize = Size(view.frame.size)
        } else {
            print("Failed to generate outputImage: \(#function)")
        }
    }
}
