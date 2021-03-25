//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public extension Int {
  func secondsToTime() -> String {
    let (h, m, s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)

    if h == 0 {
      let m_string = m < 10 ? "0\(m)" : "\(m)"
      let s_string = s < 10 ? "0\(s)" : "\(s)"

      return "\(m_string):\(s_string)"
    } else {
      let h_string = h < 10 ? "0\(h)" : "\(h)"
      let m_string = m < 10 ? "0\(m)" : "\(m)"
      let s_string = s < 10 ? "0\(s)" : "\(s)"

      return "\(h_string):\(m_string):\(s_string)"
    }
  }
}
