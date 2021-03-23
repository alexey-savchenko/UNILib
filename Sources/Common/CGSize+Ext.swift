//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

#if canImport(UIKit)

import UIKit

extension CGSize: Comparable {
  public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
    return (lhs.width * lhs.height) < (rhs.width * rhs.height)
  }
}

#endif
