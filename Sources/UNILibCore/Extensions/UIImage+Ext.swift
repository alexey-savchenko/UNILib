//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

#if canImport(UIKit)

import UIKit

public extension UIImage {
  /// Draws a new cropped and scaled (zoomed in) image.
  ///
  /// - Parameters:
  ///   - point: The center of the new image.
  ///   - scaleFactor: Factor by which the image should be zoomed in.
  ///   - size: The size of the rect the image will be displayed in.
  /// - Returns: The scaled and cropped image.
  func scaledImage(
    atPoint point: CGPoint,
    scaleFactor: CGFloat,
    targetSize size: CGSize
  ) -> UIImage? {
    guard let cgImage = self.cgImage else { return nil }
    
    let scaledSize = CGSize(width: size.width / scaleFactor, height: size.height / scaleFactor)
    let midX = point.x - scaledSize.width / 2.0
    let midY = point.y - scaledSize.height / 2.0
    let newRect = CGRect(x: midX, y: midY, width: scaledSize.width, height: scaledSize.height)
    
    guard let croppedImage = cgImage.cropping(to: newRect) else {
      return nil
    }
    
    return UIImage(cgImage: croppedImage)
  }
  
  /// Scales the image to the specified size in the RGB color space.
  ///
  /// - Parameters:
  ///   - scaleFactor: Factor by which the image should be scaled.
  /// - Returns: The scaled image.
  func scaledImage(scaleFactor: CGFloat) -> UIImage? {
    guard let cgImage = self.cgImage else { return nil }
    
    let customColorSpace = CGColorSpaceCreateDeviceRGB()
    
    let width = CGFloat(cgImage.width) * scaleFactor
    let height = CGFloat(cgImage.height) * scaleFactor
    let bitsPerComponent = cgImage.bitsPerComponent
    let bytesPerRow = cgImage.bytesPerRow
    let bitmapInfo = cgImage.bitmapInfo.rawValue
    
    guard let context = CGContext(
      data: nil,
      width: Int(width),
      height: Int(height),
      bitsPerComponent: bitsPerComponent,
      bytesPerRow: bytesPerRow,
      space: customColorSpace,
      bitmapInfo: bitmapInfo
    ) else { return nil }
    
    context.interpolationQuality = .high
    context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
    
    return context.makeImage().flatMap { UIImage(cgImage: $0) }
  }
  
  /// Returns the data for the image in the PDF format
  func pdfData() -> Data? {
    // Typical Letter PDF page size and margins
    let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
    let margin: CGFloat = 40
    
    let imageMaxWidth = pageBounds.width - (margin * 2)
    let imageMaxHeight = pageBounds.height - (margin * 2)
    
    let image = scaledImage(scaleFactor: size.scaleFactor(forMaxWidth: imageMaxWidth, maxHeight: imageMaxHeight)) ?? self
    let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
    
    let data = renderer.pdfData { (ctx) in
      ctx.beginPage()
      
      ctx.cgContext.interpolationQuality = .high
      
      image.draw(at: CGPoint(x: margin, y: margin))
    }
    
    return data
  }
  
  /// Function gathered from [here](https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer) to convert UIImage to CVPixelBuffer
  ///
  /// - Returns: new [CVPixelBuffer](apple-reference-documentation://hsVf8OXaJX)
  func pixelBuffer() -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBufferOpt: CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBufferOpt)
    guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOpt else {
      return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
      return nil
    }
    
    context.translateBy(x: 0, y: self.size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context)
    self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    
    return pixelBuffer
  }
  
  /// Creates a UIImage from the specified CIImage.
  static func from(ciImage: CIImage) -> UIImage {
    if let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) {
      return UIImage(cgImage: cgImage)
    } else {
      return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
    }
  }
  
  func fixedOrientation() -> UIImage? {
    guard imageOrientation != UIImage.Orientation.up else {
      // This is default orientation, don't need to do anything
      return self.copy() as? UIImage
    }

    guard let cgImage = self.cgImage else {
      // CGImage is not available
      return nil
    }

    guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(
      data: nil,
      width: Int(size.width),
      height: Int(size.height),
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      return nil // Not able to create CGContext
    }

    var transform: CGAffineTransform = CGAffineTransform.identity

    switch imageOrientation {
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

    // Flip image one more time if needed to, this is to prevent flipped image
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

    ctx.concatenate(transform)

    switch imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }

    guard let newCGImage = ctx.makeImage() else { return nil }
    return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
  }

  /// Represents a scaling mode
  enum ScalingMode {
    case aspectFill
    case aspectFit

    /// Calculates the aspect ratio between two sizes
    ///
    /// - parameters:
    ///     - size:      the first size used to calculate the ratio
    ///     - otherSize: the second size used to calculate the ratio
    ///
    /// - return: the aspect ratio between the two sizes
    func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
      let aspectWidth = size.width / otherSize.width
      let aspectHeight = size.height / otherSize.height

      switch self {
      case .aspectFill:
        return max(aspectWidth, aspectHeight)
      case .aspectFit:
        return min(aspectWidth, aspectHeight)
      }
    }
  }

  /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
  ///
  /// - parameter:
  ///     - newSize:     the size of the bounds the image must fit within.
  ///     - scalingMode: the desired scaling mode
  ///
  /// - returns: a new scaled image.
  func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
    let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)

    /* Build the rectangle representing the area to be drawn */
    var scaledImageRect = CGRect.zero

    scaledImageRect.size.width = size.width * aspectRatio
    scaledImageRect.size.height = size.height * aspectRatio
    scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
    scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio) / 2.0

    /* Draw and retrieve the scaled image */
    UIGraphicsBeginImageContext(newSize)

    draw(in: scaledImageRect)
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return scaledImage!
  }
  
  func tinted(_ tintColor: UIColor) -> UIImage {
    var image = withRenderingMode(.alwaysTemplate)
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    tintColor.set()
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image.withRenderingMode(.alwaysOriginal)
  }
  
  func rotateImage(radians: CGFloat) -> UIImage {
    let ciImage = CIImage(image: self)

    let filter = CIFilter(name: "CIAffineTransform")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setDefaults()

    let newAngle = radians * CGFloat(-1)

    var transform = CATransform3DIdentity
    transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
    transform = CATransform3DRotate(transform, 0, 0, 1, 0)
    transform = CATransform3DRotate(transform, 0, 1, 0, 0)

    let affineTransform = CATransform3DGetAffineTransform(transform)
    filter?.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
    let contex = CIContext(
      mtlDevice: MTLCreateSystemDefaultDevice()!,
      options: [.useSoftwareRenderer: false]
    )
    let outputImage = filter?.outputImage
    let cgImage = contex.createCGImage(outputImage!, from: (outputImage?.extent)!)
    let result = UIImage(cgImage: cgImage!)
    return result
  }
  
  convenience init?(
    color: UIColor,
    size: CGSize = CGSize(width: 1, height: 1)
  ) {
    let rect = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, .zero)

    color.setFill()
    UIRectFill(rect)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard
      let cgImage = image?.cgImage
    else {
      return nil
    }

    self.init(cgImage: cgImage)
  }
}

public extension UIImage.Orientation {
  init(_ cgOrientation: UIImage.Orientation) {
    switch cgOrientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    }
  }
}

#endif
