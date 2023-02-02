
import SwiftUI

extension UIImage {
    public func diagonalCrop(_ points: (a: CGPoint, b: CGPoint), height: CGFloat) -> UIImage {

        let cPoints = computeRectPoints(points, height: height)
        let bounds = boundingRect(cPoints)
        let bboxCropImage = cropImage(self, toRect: bounds)

        let vec = CGPoint(x: points.b.x - points.a.x, y: points.b.y - points.a.y)
        let width = sqrt(vec.x*vec.x + vec.y*vec.y)
        let angle = atan2(vec.y, vec.x)

        let rotatedImage = rotate(bboxCropImage, angle: angle)

        let cropRect = CGRect(origin: CGPoint(x: (rotatedImage.size.width - width)/2,
                                              y: (rotatedImage.size.height - height)/2),
                              size: CGSize(width: width, height: height))

        return cropImage(rotatedImage, toRect: cropRect)
    }

    func cropImage(_ image: UIImage, toRect: CGRect) -> UIImage {

        let cgImage: CGImage = (image.cgImage?.cropping(to: toRect))!

        return UIImage(cgImage: cgImage)
    }

    func computeRectPoints(_ points: (a: CGPoint, b: CGPoint), height: CGFloat) -> (a: CGPoint, b: CGPoint, c: CGPoint, d:CGPoint) {
        let c = computePoint(points, height: height, clockwise: true)
        let d = computePoint(points, height: height, clockwise: false)

        return (a: points.a, b: points.b, c: c, d: d)
    }

    func computePoint(_ points: (a: CGPoint, b: CGPoint), height: CGFloat, clockwise: Bool) -> CGPoint {
        let x = clockwise ? points.b : points.a
        let y = clockwise ? points.a : points.b

        let mult: CGFloat = clockwise ? 1 : -1

        let len = sqrt(pow((x.x - y.x),2) + pow((x.y - y.y),2))

        let cx = x.x + ((height * (y.y - x.y))/len * mult)
        let cy = x.y + ((height * (x.x - y.x))/len * mult)

        return CGPoint(x: cx, y: cy)
    }

    func boundingRect(_ points: (a: CGPoint, b: CGPoint, c: CGPoint, d:CGPoint)) -> CGRect {
        let minX = min(min(points.a.x, points.b.x), min(points.c.x, points.d.x))
        let minY = min(min(points.a.y, points.b.y), min(points.c.y, points.d.y))

        let maxX = max(max(points.a.x, points.b.x), max(points.c.x, points.d.x))
        let maxY = max(max(points.a.y, points.b.y), max(points.c.y, points.d.y))

        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }

    func rotate(_ image: UIImage, angle: CGFloat) -> UIImage {
        if let imgRef = image.cgImage {

            let width = imgRef.width
            let height = imgRef.height

            let imgRect = CGRect(x: 0, y: 0, width: width, height: height)
            let transform = CGAffineTransform(rotationAngle:angle)
            let rotatedRect = imgRect.applying(transform)

            if let colorSpace = imgRef.colorSpace {
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).union(CGBitmapInfo.byteOrder32Big)
                if let bmContext = CGContext.init(data: nil,
                                                  width: Int(rotatedRect.size.width),
                                                  height: Int(rotatedRect.size.height),
                                                  bitsPerComponent: 8,
                                                  bytesPerRow: 0,
                                                  space: colorSpace,
                                                  bitmapInfo: bitmapInfo.rawValue) {

                    bmContext.setAllowsAntialiasing(true)
                    bmContext.interpolationQuality = .default
                    bmContext.translateBy(x: rotatedRect.size.width/2, y: rotatedRect.size.height/2)
                    bmContext.rotate(by: angle)
                    bmContext.translateBy(x: -rotatedRect.size.width/2, y: -rotatedRect.size.height/2)
                    bmContext.draw(imgRef, in: CGRect(origin: CGPoint(x: (rotatedRect.size.width - CGFloat(width))/2,
                                                                      y: (rotatedRect.size.height - CGFloat(height))/2),
                                                      size: CGSize(width: width, height: height)))

                    if let cgImage = bmContext.makeImage() {
                        return UIImage.init(cgImage: cgImage)
                    }

                    return image
                }
                return image
            }
            return image
        }
        return image
    }
}
