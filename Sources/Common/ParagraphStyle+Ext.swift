//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

#if canImport(UIKit)

import UIKit

public extension NSParagraphStyle {
  static var centered: NSParagraphStyle {
    let p = NSMutableParagraphStyle()
    p.alignment = .center
    return p
  }
}

#endif
