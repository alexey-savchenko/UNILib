//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 15.12.2020.
//

import Foundation

public extension FloatingPoint {
  
  func transform(
    sourceScale: ClosedRange<Self>,
    targetScaleScale: ClosedRange<Self>
  ) -> Self {
    
    let a: Self = targetScaleScale.lowerBound + (self - sourceScale.lowerBound)
    let b: Self = targetScaleScale.upperBound - targetScaleScale.lowerBound
    let c: Self = sourceScale.upperBound - sourceScale.lowerBound
    
    return a * b / c
  }
}
