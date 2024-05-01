//
//  ParkingRateViewController.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/6/22.
//

import UIKit

class ParkingRateViewController: UIViewController {
    
    @IBOutlet weak var halfHourLabel: UILabel!
    @IBOutlet weak var halfToOneHourLabel: UILabel!
    @IBOutlet weak var oneToTwoHourLabel: UILabel!
    @IBOutlet weak var twoToThreeHourLabel: UILabel!
    @IBOutlet weak var threeToFourHourLabel: UILabel!
    @IBOutlet weak var fourToTwentyFourHourLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Parking Rates"
        navigationController?.setTheme(theme: .whiteTheme())
        
        getParkingRates()
    }
    
    func getParkingRates() {
        API.shared.getParkingRates {[weak self] rates, error in
            guard let `self` = self else {return}
            print(error ?? "")
            
            self.halfHourLabel.text = rates?.halfHour.toString
            self.halfToOneHourLabel.text = rates?.halfToOneHour.toString
            self.oneToTwoHourLabel.text = rates?.oneToTwoHour.toString
            self.twoToThreeHourLabel.text = rates?.twoToThreeHour.toString
            self.threeToFourHourLabel.text = rates?.threeToFourHour.toString
            self.fourToTwentyFourHourLabel.text = rates?.fourToTwentyFourHour.toString
        }
    }
    
}
