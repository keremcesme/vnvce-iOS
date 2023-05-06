
import UIKit

extension UIImage {
    func fixedOrientation() -> UIImage? {
        
        guard self.imageOrientation != .up else {
            return self
        }
        
        let size = self.size
        
        let imageOrientation = self.imageOrientation
        
        var transform: CGAffineTransform = .identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip self one more time if needed to, this is to prevent flipped self
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        guard var cgImage = self.cgImage else {
            return nil
        }
        
        autoreleasepool {
            var context: CGContext?
            
            guard let colorSpace = cgImage.colorSpace, let _context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                return
            }
            context = _context
            
            context?.concatenate(transform)

            var drawRect: CGRect = .zero
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                drawRect.size = CGSize(width: size.height, height: size.width)
            default:
                drawRect.size = CGSize(width: size.width, height: size.height)
            }

            context?.draw(cgImage, in: drawRect)
            
            guard let newCGImage = context?.makeImage() else {
                return
            }
            cgImage = newCGImage
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
        return uiImage
    }
    
    func compressImage(size: Int) throws -> Data {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.02
        
        guard var uploadImageData = self.jpegData(compressionQuality: compression) else {
            print("Compress Error")
            throw NSError(domain: "Compress Error", code: 1)
        }
        
        while (uploadImageData.count > size) && (compression > maxCompression) {
            compression -= 0.05
            if let compressedImageData = self.jpegData(compressionQuality: compression) {
                uploadImageData = compressedImageData
//                print(compressedImageData.count)
            }
        }
        
        guard let data = self.jpegData(compressionQuality: compression) else {
            print("ERROR: Compressing final photo")
            throw NSError(domain: "Compressing final photo", code: 1)
        }
        
        return data
    }
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
