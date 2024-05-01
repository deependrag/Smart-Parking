//
//  UINavigationController+Extension.swift
//  HR APP
//
//  Created by Deependra Dhakal on 8/4/20.
//  Copyright © 2020 info Developers. All rights reserved.
//

import UIKit

extension UINavigationController {
    enum NavBarTheme {
        case whiteTheme(_ textColor: UIColor = UIColor.darkText)
        case transparent(_ tintColor: UIColor = UIColor.darkText)
    }
    
    func setTheme(theme: NavBarTheme) {
        switch theme {
        case .whiteTheme:
            self.navigationBar.isTranslucent = false
            self.navigationBar.barTintColor = .UH
            self.navigationBar.tintColor = .white
            self.navigationBar.backgroundColor = .UH
            self.navigationBar.shadowImage = UIImage()
            if #available(iOS 13.0, *) {
                let app = UINavigationBarAppearance()
                app.backgroundColor = .UH
                app.titleTextAttributes = [.foregroundColor: UIColor.white]
                self.navigationBar.scrollEdgeAppearance = app
                self.navigationBar.standardAppearance = app
            } else {
                self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            }
            
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationBar.titleTextAttributes = textAttributes
            
        case .transparent(let color):
            self.navigationBar.isTranslucent = true
            
            if #available(iOS 13.0, *) {
                let app = UINavigationBarAppearance()
                app.backgroundColor = UIColor.clear
                app.configureWithTransparentBackground()// the gradient image
                self.navigationBar.scrollEdgeAppearance = app
                self.navigationBar.standardAppearance = app
            } else {
                self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            }

            self.navigationBar.backgroundColor = .clear
            self.navigationBar.tintColor = color
            self.navigationBar.shadowImage = UIImage()
            let textAttributes = [NSAttributedString.Key.foregroundColor: color]
            self.navigationBar.titleTextAttributes = textAttributes
          
        }
    }

    func removeBackTitle() {
        self.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}
