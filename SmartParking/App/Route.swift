//
//  Route.swift
//  Delivey App
//
//  Created by Deependra Dhakal on 13/01/2021.
//

import UIKit

enum NavigationRoute {
    case home
    case parkingRates
    case registerCar
}

extension UIViewController {
    func navigateTo(
        route: NavigationRoute,
        makeRoot: Bool = false,
        makeRootWithNavigation: Bool = false,
        present: Bool = false,
        presentWithNavigation: Bool = false,
        dismissCompletion: ((String?) -> Void)? = nil
    ) {
        
        var viewController: UIViewController!
        
        switch route {
        case .home:
            let homeVC : LPRViewController = LPRViewController.instantiate(appStoryboard: .home)
            let navigation = UINavigationController(rootViewController: homeVC)
            viewController = navigation
            
        case .parkingRates:
            viewController = ParkingRateViewController.instantiate(appStoryboard: .parking)
        
        case .registerCar:
            viewController = RegisterCarViewController.instantiate(appStoryboard: .home)

        }
        
        
        
        if makeRoot || makeRootWithNavigation {
            let window = self.view.window
            
            if makeRootWithNavigation {
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.setTheme(theme: .whiteTheme(.colorBlack))
                window?.switchRootViewController(navigationController)
            }else {
                window?.switchRootViewController(viewController)
            }
            
            window?.makeKeyAndVisible()
        }else {
            if present || presentWithNavigation {
                if presentWithNavigation {
                    let navigationController = UINavigationController(rootViewController: viewController)
                    navigationController.setTheme(theme: .whiteTheme(.colorBlack))
                    self.present(navigationController, animated: true, completion: nil)
                    return
                }
                self.present(viewController, animated: true, completion: nil)
                
            }else {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
