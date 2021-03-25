//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public extension NSMutableAttributedString {
  var fromStartToEnd: NSRange {
    return mutableString.range(of: string)
  }
}
