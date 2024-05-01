//
//  UIViewController+Extension.swift
//  Foreveryng
//
//  Created by Deependra Dhakal on 9/30/20.
//

import UIKit

extension UIViewController {
    func addLogo() {
        let titleImageView = UIImage(named: "logo-red")
        let logoBarButton = UIBarButtonItem(image: titleImageView, style: .plain, target: nil, action: nil)
        logoBarButton.imageInsets.left = -20
        logoBarButton.isEnabled = false
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = logoBarButton
    }

    
    //MARK:- ALERT
    func showAlertWithAction(title: String?, message : String?,  closure : (() -> ())? = nil){
        let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let alertAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default){ _ in
            closure?()
        }
        alertView.addAction(noAction)
        alertView.addAction(alertAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func showAlert(title: String = "Success", message : String, buttonTitle: String = "Ok", closure : (() -> ())? = nil){
        let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.cancel, handler: {_ in
            closure?()
        })
        alertView.addAction(alertAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func showAlertWith3Action(title: String?, message : String?,  closureYes : @escaping () -> (), closureNext : @escaping () -> ()){
        let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let noAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        let alertAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive){ _ in
            closureYes()
        }
        
        let alertAction1: UIAlertAction = UIAlertAction(title: "Move to wishlist", style: UIAlertAction.Style.default){ _ in
            closureNext()
        }
        
        alertView.addAction(alertAction)
        alertView.addAction(alertAction1)
        alertView.addAction(noAction)
        self.present(alertView, animated: true, completion: nil)
    }
}
