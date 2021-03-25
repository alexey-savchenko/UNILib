//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import CoreGraphics

/**
 The `FloatingPointMath` protocol declares 3 mathematical operations that
 let us write functions and algorithms that use Sine, Cosine and power of 2
 math, and work on any floating-point type.
 */
public protocol FloatingPointMath: FloatingPoint {
  /// The mathematical sine of a floating-point value.
  var sine: Self { get }

  /// The mathematical cosine of a floating-point value.
  var cosine: Self { get }

  /**
   The power base 2 of a floating-point value.
   In the next example 'y' has a value of '3.0'.
   The powerOfTwo of 'y' is therefore '8.0'.

   let y: Double = 3.0
   let p = y.powerOfTwo
   print(p)  // "8.0"
   */
  var powerOfTwo: Self { get }

  static var pi: Self { get }

  init(_ v: Double)

  static var _pow: (_ f: Self, _ s: Self) -> Self { get }
}

// extension FloatingPointMath {
//  static func sin() -> (Self) -> Self {
//    return
//  }
// }

// MARK: - FloatingPointMath extension for Float.
extension Float: FloatingPointMath {
  public var sine: Float {
    return sin(self)
  }

  public var cosine: Float {
    return cos(self)
  }

  public var powerOfTwo: Float {
    return pow(2, self)
  }

  public static var _pow: (Float, Float) -> Float {
    return powf
  }
}

// MARK: - FloatingPointMath extension for Double.
extension Double: FloatingPointMath {
  public var sine: Double {
    return sin(self)
  }

  public var cosine: Double {
    return cos(self)
  }

  public var powerOfTwo: Double {
    return pow(2, self)
  }

  public static var _pow: (Double, Double) -> Double {
    return pow
  }
}

// MARK: - FloatingPointMath extension for Double.
extension CGFloat: FloatingPointMath {
  public var sine: CGFloat {
    return sin(self)
  }

  public var cosine: CGFloat {
    return cos(self)
  }

  public var powerOfTwo: CGFloat {
    return pow(2, self)
  }

  public static var _pow: (CGFloat, CGFloat) -> CGFloat {
    return { a, b -> CGFloat in CGFloat(pow(Double(a), Double(b))) }
  }
}

