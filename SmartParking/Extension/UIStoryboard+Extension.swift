//
//  UIStoryboard+Extension.swift
//  Foreveryng
//
//  Created by Deependra Dhakal on 9/28/20.
//

import UIKit

enum AppStoryboard: String {
    case home = "Home"
    case parking = "Parking"
}

extension UIViewController {
    class func instantiate<T: UIViewController>(appStoryboard: AppStoryboard) -> T {

        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}

extension UIApplication {
    /// The top most view controller
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.visbleViewController
    }
}

extension UIViewController {
    /// The visible view controller from a given view controller
    var visbleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visbleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visbleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visbleViewController
        } else {
            return self
        }
    }
}


extension UIWindow {
    
    func switchRootViewController(_ viewController: UIViewController,
                                  animated: Bool = true,
                                  duration: TimeInterval = 0.5,
                                  options: AnimationOptions = .curveEaseIn,
                                  completion: (() -> Void)? = nil) {
        guard animated else {
            rootViewController = viewController
            return
        }
        
        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
    
}
