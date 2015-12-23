//
//  ErrorViewController.swift
//  company
//
//  Created by Oleg Abakumov on 15.04.15.
//  Copyright (c) 2015 Oleg Abakumov. All rights reserved.
//

import Foundation
import UIKit

class ErrorViewController: APIModelErrorViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.errorBtn?.setTitle("OK", forState: UIControlState.Normal)
        self.errorBtn?.setTitle("OK", forState: UIControlState.Selected)
        self.errorBtn?.setTitle("OK", forState: UIControlState.Reserved)
        self.errorBtn?.setTitle("OK", forState: UIControlState.Disabled)
        self.errorBtn?.setTitle("OK", forState: UIControlState.Application)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Интернет недоступен"
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.errorBtn?.layer.cornerRadius = 5.0
        self.errorBtn?.layer.borderColor = UIColor(red: 13/255, green: 151/255, blue: 43/255, alpha: 1).CGColor
        self.errorBtn?.layer.borderWidth = 1
        self.errorBtn?.layer.masksToBounds = true
    }
}