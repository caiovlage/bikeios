//
//  HelpController.swift
//  bikeios
//
//  Created by caio victor lage on 26/08/19.
//  Copyright © 2019 caio victor lage. All rights reserved.

import UIKit

class HelpController: UIViewController {
    
    var telefone = ""
    
    @IBAction func callPhone(_ sender: UIButton) {
        guard let number = URL(string: "tel://" + "(21)2443-0591") else { return }
        UIApplication.shared.open(number)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
