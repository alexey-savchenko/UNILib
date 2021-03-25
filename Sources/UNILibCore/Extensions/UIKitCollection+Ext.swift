//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 18.12.2020.
//

#if canImport(UIKit)

import UIKit

public protocol ReusableView: class {}

public extension ReusableView where Self: UIView {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UIView: ReusableView {}

public extension UICollectionView {
  func dequeueReusableCell<T>(forIndexPath indexPath: IndexPath) -> T where T: UICollectionViewCell {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
    }
    return cell
  }
    
  func registerClass<T: UICollectionViewCell>(_: T.Type) {
    register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func visibleCellInCenter<T: UICollectionViewCell>(_: T.Type) -> T? {
    let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    return indexPathForItem(at: visiblePoint).map(cellForItem(at:)) as? T
  }
}

public extension UITableView {
  
  func dequeueReusableCell<T>(forIndexPath indexPath: IndexPath) -> T where T: UITableViewCell {
    guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
    }
    return cell
  }
  
  func registerClass<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
  }

  func dequeueReusableHeader<T>() -> T where T: UITableViewHeaderFooterView {
    guard let header = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
    }
    return header
  }
  
  func registerClassForDequeueReusableHeaderView<T: UITableViewHeaderFooterView>(_: T.Type) -> T? {
    self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
  }
}

#endif
