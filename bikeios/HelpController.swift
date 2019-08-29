//
//  HelpController.swift
//  bikeios
//
//  Created by caio victor lage on 26/08/19.
//  Copyright © 2019 caio victor lage. All rights reserved.

import UIKit

class HelpController: UIViewController {
    
    var telefone = ""
    @IBOutlet weak var Phone: UIView!
    
     
    @IBAction func callPhone(_ sender: UIButton) {
        guard let number = URL(string: "tel://" + telefone) else { return }
        UIApplication.shared.open(number)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Phone.dropShadow()
    }
    
  
}
extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
