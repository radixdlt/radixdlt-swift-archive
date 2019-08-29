//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import SwiftUI

// MARK: QRCodeImage
struct QRCodeImage {
    private let data: Data
    init(data: Data) {
        self.data = data
    }
}

extension QRCodeImage: View {
    var body: some View {
        Image(uiImage: self.uiImage).resizable().aspectRatio(contentMode: .fill)
    }
}

// MARK: Convenience Init
extension QRCodeImage {
    init(string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Create data from string")
        }

        self.init(data: data)
    }
}

extension QRCodeImage {
    var uiImage: UIImage {
        guard let image = imageScaled(scale: 100) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Generated QR image from data")
        }
        return image
    }
}

private extension QRCodeImage {
    /// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator
    func imageScaled(scale: CGFloat) -> UIImage? {

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        let context = CIContext(options: nil)

        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage, scale: scale, orientation: .up).resized(resizingScale: scale)
    }
}

private extension UIImage {
    func resized(
        interpolationQuality: CGInterpolationQuality = .none,
        resizingScale rate: CGFloat
    ) -> UIImage? {

        let width = size.width * rate
        let height = size.height * rate
        let size = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.interpolationQuality = interpolationQuality

        let rect = CGRect(origin: .zero, size: size)

        draw(in: rect)

        guard let resized = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()

        return resized
    }
}
