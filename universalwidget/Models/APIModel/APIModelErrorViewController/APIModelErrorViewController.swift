//
//  APIModelErrorViewController.swift
//  company
//
//  Created by Oleg Abakumov on 15.04.15.
//  Copyright (c) 2015 Oleg Abakumov. All rights reserved.
//

import Foundation
import UIKit

@objc protocol APIModelErrorViewDelegate : NSObjectProtocol {
    func errorBtnTap(sender: AnyObject, controller: AnyObject)
    
}

class APIModelErrorViewController: UIViewController {
    @IBOutlet var errorBtn : UIButton?
    
    var delegate : APIModelErrorViewDelegate?
    
    @IBAction func errorBtnTap(sender: AnyObject) {
        if ((self.delegate?.respondsToSelector(Selector("errorBtnTap:controller:"))) != false) {
            self.delegate?.errorBtnTap(sender, controller: self)
        }
    }
}