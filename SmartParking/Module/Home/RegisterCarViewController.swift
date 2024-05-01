//
//  ViewController.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/6/22.
//

import UIKit
import IBAnimatable
import FirebaseFirestore

class RegisterCarViewController: UIViewController {
    @IBOutlet weak var licensePlateTextField: AnimatableTextField!
    @IBOutlet weak var nameTextField: AnimatableTextField!
    @IBOutlet weak var validTillTextField: AnimatableTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Register Car"
        navigationController?.setTheme(theme: .whiteTheme())
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton){
        guard let licensePlateNumber = licensePlateTextField.text,
              let name = nameTextField.text,
              let validTill = validTillTextField.text
        else {
            self.showAlert(message: "Enter all field values")
            return
        }
        
        let registerCarModel = RegisteredVehicle(
            licensePlate: licensePlateNumber,
            name: name,
            registered: Timestamp(),
            valid: validTill
        )
        
        API.shared.registerVehicle(model: registerCarModel) { result, error in
            if result ?? false {
                self.showAlert(message: "Vehicle Registered", closure: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}


