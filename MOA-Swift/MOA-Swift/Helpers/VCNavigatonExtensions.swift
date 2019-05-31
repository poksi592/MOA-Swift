//
//  VCNavigatonExtensions.swift
//  MOA-Swift
//
//  Created by Mladen Despotovic on 30.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

public protocol VCNavigatonExtensions {
    
    var application: UIApplication { get set }
    var rootVc: UIViewController? { get set }
    var tempRootVc: UIViewController? { get set }
    var topPresentedController: UIViewController? { get }
    var topmostNavigationController: UINavigationController? { get }
    var topNavigatedController: UIViewController? { get }
}

extension VCNavigatonExtensions {
    
    var rootVc: UIViewController? {
        get {
            return self.tempRootVc ?? application.keyWindow?.rootViewController
        }
        set(newRootVc) {
            self.tempRootVc = newRootVc
        }
    }
    
    func topViewController(baseVc: UIViewController? = nil) -> UIViewController? {
        
        let base = baseVc != nil ? baseVc : rootVc
        if let navVc = base as? UINavigationController {
            return topViewController(baseVc: navVc.visibleViewController)
        } else if let tabVc = base as? UITabBarController,
          let selectedVc = tabVc.selectedViewController {
            return topViewController(baseVc: selectedVc)
        } else if let presentedVc = base?.presentedViewController {
            return topViewController(baseVc: presentedVc)
        }
        return base
    }
    
    var topPresentedController: UIViewController? {
        
        var topViewController = rootVc
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    func topPresentedController(viewController: UIViewController) -> UIViewController? {
        
        var topViewController = viewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    var topNavigatedController: UIViewController? {
        return topmostNavigationController?.visibleViewController
    }
    
    var topmostNavigationController: UINavigationController? {
        return topViewController()?.navigationController
    }
}
