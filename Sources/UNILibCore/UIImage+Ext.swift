//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

#if canImport(UIKit)

import UIKit

public extension UIImage {
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

    guard let cgImage = image?.cgImage else {
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
