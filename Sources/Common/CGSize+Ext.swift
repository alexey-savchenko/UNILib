//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

import CoreGraphics

extension CGSize: Comparable {
  public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
    return (lhs.width * lhs.height) < (rhs.width * rhs.height)
  }
}

public extension CGSize {
  static func aspectFit(videoSize: CGSize, boundingSize: CGSize) -> CGSize {
    var size = boundingSize
    let mW = boundingSize.width / videoSize.width
    let mH = boundingSize.height / videoSize.height

    if mH < mW {
      size.width = boundingSize.height / videoSize.height * videoSize.width
    } else if mW < mH {
      size.height = boundingSize.width / videoSize.width * videoSize.height
    }

    return size
  }

  static func aspectFill(videoSize: CGSize, boundingSize: CGSize) -> CGSize {
    var size = boundingSize
    let mW = boundingSize.width / videoSize.width
    let mH = boundingSize.height / videoSize.height

    if mH > mW {
      size.width = boundingSize.height / videoSize.height * videoSize.width
    } else if mW > mH {
      size.height = boundingSize.width / videoSize.width * videoSize.height
    }

    return size
  }
}

public typealias PositionParams = (scale: CGSize, position: CGPoint)

public func scaleAndPositionInAspectFillMode(
  _ inputSize: CGSize,
  in area: CGSize
) -> PositionParams {
  let assetSize = inputSize
  let aspectFillSize = CGSize.aspectFill(videoSize: assetSize, boundingSize: area)
  let aspectFillScale = CGSize(width: aspectFillSize.width / assetSize.width, height: aspectFillSize.height / assetSize.height)
  let position = CGPoint(x: (area.width - aspectFillSize.width) / 2.0, y: (area.height - aspectFillSize.height) / 2.0)
  return (scale: aspectFillScale, position: position)
}

public func scaleAndPositionInAspectFitMode(
  _ inputSize: CGSize,
  in area: CGSize
) -> PositionParams {
  let assetSize = inputSize
  let aspectFitSize = CGSize.aspectFit(videoSize: assetSize, boundingSize: area)
  let aspectFitScale = CGSize(width: aspectFitSize.width / assetSize.width, height: aspectFitSize.height / assetSize.height)
  let position = CGPoint(x: (area.width - aspectFitSize.width) / 2.0, y: (area.height - aspectFitSize.height) / 2.0)
  return (scale: aspectFitScale, position: position)
}
