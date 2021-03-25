//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 15.12.2020.
//

#if canImport(UIKit)

import UIKit

public protocol PresentationContext: class {
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
