//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 15.12.2020.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// Helps with visualisation of CGRects in 2D plane
public func drawRects(
  _ rects: [String: CGRect],
  canvas: CGRect? = nil
) -> UIImage {
  
  let rawBounds = canvas ?? rects.values.reduce(CGRect.zero) { (res, elem) -> CGRect in
    return res.union(elem)
  }
  let bounds = rawBounds.insetBy(dx: -50, dy: -50)
  let labelAttrs: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]

  let renderer = UIGraphicsImageRenderer(bounds: bounds)
  return renderer.image { (ctx) in
    UIColor.lightGray.setFill()
    let _bgPath = UIBezierPath(rect: bounds)
    ctx.cgContext.addPath(_bgPath.cgPath)
    _bgPath.fill()
    
    UIColor.white.setFill()
    let bgPath = UIBezierPath(rect: rawBounds)
    ctx.cgContext.addPath(bgPath.cgPath)
    bgPath.fill()
    
    rects.forEach { label, rect in
      let color = UIColor(red: CGFloat.random(in: 0..<1),
                          green: CGFloat.random(in: 0..<1),
                          blue: CGFloat.random(in: 0..<1),
                          alpha: 1)
      color.withAlphaComponent(0.5).setFill()
      color.setStroke()

      let path = UIBezierPath(rect: rect)

      ctx.cgContext.addPath(path.cgPath)
      path.fill()
      path.stroke()
      
      let labelString = NSString(string: label)
      let labelStringBounds = labelString.boundingRect(with: rect.size,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: labelAttrs,
                                                       context: nil)
      let labelStringRect = CGRect(x: rect.midX - labelStringBounds.width / 2,
                                   y: rect.minY,
                                   width: labelStringBounds.width,
                                   height: labelStringBounds.height)
      labelString.draw(in: labelStringRect, withAttributes: labelAttrs)
    }
  }
}

#endif
 
