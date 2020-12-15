//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 15.12.2020.
//

#if canImport(UIKit)

import UIKit

public enum PresentationContext {
  case push(presentingController: UINavigationController)
  case modal(presentingController: UIViewController)
  
  public var navigationController: UINavigationController? {
    switch self {
    case .push(let presentingController):
      return presentingController
    default:
      return nil
    }
  }
  
  public func present(_ target: UIViewController, animated: Bool) {
    switch self {
    case .modal(let presentingController):
      presentingController.present(target,
                                   animated: animated,
                                   completion: nil)
    case .push(let presentingController):
      presentingController.pushViewController(target,
                                              animated: animated)
    }
  }
  
  public func dismiss(_ target: UIViewController, animated: Bool) {
    switch self {
    case .modal:
      target.dismiss(animated: animated, completion: nil)
    case .push(let presentingController):
      presentingController.popViewController(animated: animated)
    }
  }
  
  public func dismissToRoot(_ target: UIViewController, animated: Bool) {
    switch self {
    case .modal:
      target.dismiss(animated: animated, completion: nil)
    case .push(let presentingController):
      presentingController.popToRootViewController(animated: true)
    }
  }
  
  public func dismissPresented(animated: Bool) {
    switch self {
    case .push(let presentingController):
      presentingController.popViewController(animated: animated)
    case .modal(let presentingController):
      presentingController.presentedViewController.do { $0.dismiss(animated: animated) }
    }
  }
}

#endif
