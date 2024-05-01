//
//  UIImageView+Extension.swift
//  Foreveryng
//
//  Created by Deependra Dhakal on 20/11/2020.
//

import UIKit

extension UIImage {
    // MARK: - UIImage+Resize
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedToKB(sizeInKB : Double, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            guard let imageData = self.pngData() else { return completion(nil)}
            let megaByte = sizeInKB
            
            var resizingImage = self
            var imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
            
            while imageSizeKB > megaByte { // ! Or use 1024 if you need KB but not kB
                guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                      let imageData = resizedImage.pngData() else { return }
                
                resizingImage = resizedImage
                imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
            }
            DispatchQueue.main.async {
                completion(resizingImage)
            }
        }
    }
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
