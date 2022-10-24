//
//  CameraManager+Export.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import SwiftUI
import AVFoundation

enum ExportImageResult {
    case success(UIImage)
    case error
}

extension CameraManager {
    
    public func exportImage(completion: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.main.async {
            if let image = self.image  {
                let width: CGFloat = 1440.0
                let height: CGFloat = 2560.0
                
                let canvasSize: CGSize = CGSize(width: width, height: height)
                
                self.calculateImageSize(imageSize: image.size, canvasSize: canvasSize) { size in
                    let format = UIGraphicsImageRendererFormat()
                    format.scale = 1
                    
                    let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
                    
                    let renderedImage = renderer.image { context in
                        image.draw(in: size)
                    }
                    
                    return completion(renderedImage)
                }
            }
        }
    }
    
    
    private func calculateImageSize(
        imageSize: CGSize,
        canvasSize: CGSize,
        completion: @escaping (_ size: CGRect) -> Void
    ){
        let xScale = imageSize.width > 0 ? canvasSize.width / imageSize.width : 1
        let yScale = imageSize.height > 0 ? canvasSize.height / imageSize.height : 1
        
        let scale: CGFloat = (xScale > 0 && yScale > 0) ? max(xScale, yScale) : 1
        
        let scaledSize = CGSize(width: scale * imageSize.width, height: scale * imageSize.height)
        let size: CGRect = CGRect(size: CGSize(width: scaledSize.width, height: scaledSize.height),
                                  container: canvasSize,
                                  alignment: .center,
                                  inside: true)
        return completion(size)
    }
    
}

class ImageSaver: NSObject {
    public func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Image saved succesfully.")
    }
}
