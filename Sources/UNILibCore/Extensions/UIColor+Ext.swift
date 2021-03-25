//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

#if canImport(UIKit)

import UIKit

public extension UIColor {
  convenience init(hexString: String) {
    let hex = hexString
      .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

    var int = UInt32()

    Scanner(string: hex).scanHexInt32(&int)

    let a, r, g, b: UInt32

    switch hex.count {
    case 3:
      // RGB (12-bit)
      (a, r, g, b) = (
        255,
        (int >> 8) * 17,
        (int >> 4 & 0xF) * 17,
        (int & 0xF) * 17
      )
    case 6:
      // RGB (24-bit)
      (a, r, g, b) = (
        255,
        int >> 16,
        int >> 8 & 0xFF,
        int & 0xFF
      )
    case 8:
      // ARGB (32-bit)
      (a, r, g, b) = (
        int >> 24,
        int >> 16 & 0xFF,
        int >> 8 & 0xFF,
        int & 0xFF
      )
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }

    self.init(
      red: CGFloat(r) / 255,
      green: CGFloat(g) / 255,
      blue: CGFloat(b) / 255,
      alpha: CGFloat(a) / 255
    )
  }

  func getColorMatrixFilter() -> CIFilter? {
    guard
      let colorMatrix = CIFilter(name: "CIColorMatrix")
    else { return nil }

    var r: CGFloat = .zero, g: CGFloat = .zero, b: CGFloat = .zero, a: CGFloat = .zero
    self.getRed(&r, green: &g, blue: &b, alpha: &a)

    colorMatrix.setValue(CIVector(x: r, y: 0, z: 0, w: 0), forKey: "inputRVector")
    colorMatrix.setValue(CIVector(x: 0, y: g, z: 0, w: 0), forKey: "inputGVector")
    colorMatrix.setValue(CIVector(x: 0, y: 0, z: b, w: 0), forKey: "inputBVector")
    colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: a), forKey: "inputAVector")

    return colorMatrix
  }
}

public func == (lhs: UIColor, rhs: UIColor) -> Bool {
  let tolerance: CGFloat = 0.0001

  var lhsR: CGFloat = 0
  var lhsG: CGFloat = 0
  var lhsB: CGFloat = 0
  var lhsA: CGFloat = 0
  var rhsR: CGFloat = 0
  var rhsG: CGFloat = 0
  var rhsB: CGFloat = 0
  var rhsA: CGFloat = 0

  lhs.getRed(&lhsR, green: &lhsG, blue: &lhsB, alpha: &lhsA)
  rhs.getRed(&rhsR, green: &rhsG, blue: &rhsB, alpha: &rhsA)

  let redDiff = fabs(lhsR - rhsR)
  let greenDiff = fabs(lhsG - rhsG)
  let blueDiff = fabs(lhsB - rhsB)
  let alphaDiff = fabs(lhsA - rhsA)

  return redDiff < tolerance && greenDiff < tolerance && blueDiff < tolerance && alphaDiff < tolerance
}

#endif
