//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 15.12.2020.
//

#if canImport(UIKit)

import UIKit
//
//public enum PresentationContext {
//  case push(presentingController: UINavigationController)
//  case modal(presentingController: UIViewController)
//
//  public var navigationController: UINavigationController? {
//    switch self {
//    case .push(let presentingController):
//      return presentingController
//    default:
//      return nil
//    }
//  }
//
//  public func present(_ target: UIViewController, animated: Bool) {
//    switch self {
//    case .modal(let presentingController):
//      presentingController.present(target,
//                                   animated: animated,
//                                   completion: nil)
//    case .push(let presentingController):
//      presentingController.pushViewController(target,
//                                              animated: animated)
//    }
//  }
//
//  public func dismiss(_ target: UIViewController, animated: Bool) {
//    switch self {
//    case .modal:
//      target.dismiss(animated: animated, completion: nil)
//    case .push(let presentingController):
//      presentingController.popViewController(animated: animated)
//    }
//  }
//
//  public func dismissToRoot(_ target: UIViewController, animated: Bool) {
//    switch self {
//    case .modal:
//      target.dismiss(animated: animated, completion: nil)
//    case .push(let presentingController):
//      presentingController.popToRootViewController(animated: true)
//    }
//  }
//
//  public func dismissPresented(animated: Bool) {
//    switch self {
//    case .push(let presentingController):
//      presentingController.popViewController(animated: animated)
//    case .modal(let presentingController):
//      presentingController.presentedViewController.do { $0.dismiss(animated: animated) }
//    }
//  }
//}

public protocol PresentationContext {
  func present(_ controller: UIViewController, animated: Bool)
  func dismiss(_ controller: UIViewController, animated: Bool)
}

public class NavigationControllerPresentationContext: PresentationContext {
  
  let navigationController: UINavigationController
  
  public init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  public func set(_ controller: UIViewController, animated: Bool) {
    navigationController.setViewControllers([controller], animated: animated)
  }
  
  public func present(_ controller: UIViewController, animated: Bool) {
    navigationController.pushViewController(controller, animated: animated)
  }
  
  public func dismiss(_ controller: UIViewController, animated: Bool) {
    navigationController.popViewController(animated: animated)
  }
  
  public func popToRoot(animated: Bool) {
    navigationController.popToRootViewController(animated: animated)
  }
}

public class ModalPresentationContext: PresentationContext {
  
  let presentingController: UIViewController
  
  public init(presentingController: UIViewController) {
    self.presentingController = presentingController
  }
  
  public func present(_ controller: UIViewController, animated: Bool) {
    presentingController.present(controller, animated: animated)
  }
  
  public func dismiss(_ controller: UIViewController, animated: Bool) {
    controller.dismiss(animated: animated)
  }
}

#endif
