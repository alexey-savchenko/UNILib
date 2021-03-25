//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

#if canImport(UIKit)

import CoreImage
import UIKit

public extension CIImage {
  var toUIImage: UIImage? {
    let context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)
    let cgImage = context.createCGImage(self, from: self.extent)
    return cgImage.map(UIImage.init)
  }
}

#endif
