//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

#if canImport(UIKit)

import UIKit

public extension UIViewController {
  /// Add child view controller
  func add(_ child: UIViewController) {
    addChild(child)
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }

  /// Remove child view controller from parent
  func remove() {
    guard
      parent != nil
    else { return }

    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}

#endif
