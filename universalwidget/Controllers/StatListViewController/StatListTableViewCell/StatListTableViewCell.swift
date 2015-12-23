//
//  StatListTableViewCell.swift
//  universalwidget
//
//  Created by Oleg Abakumov on 11.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import Foundation
import UIKit

class StatListTableViewCell: UITableViewCell {
    @IBOutlet var typeItem : UILabel?
    @IBOutlet var titleItem : UILabel?
    @IBOutlet var switchItem : UISwitch?
    
    var url : String = ""
    var navController : UINavigationController?
    
    @IBAction func swicthValueChaged(sender: AnyObject) {
        let UD : NSUserDefaults = NSUserDefaults.init(suiteName: "group.beboss.universalwidget")!
        
        var widgets = UD.valueForKey("widgets") as? NSMutableArray
        
        if widgets == nil {
            widgets = NSMutableArray()
        }
        
        if (widgets?.count > 4) {
            let alertController = UIAlertController(title: "Слишком много виджетов", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Default, handler: nil))
            
            self.navController?.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            if ((sender as! UISwitch).on) {
                let widget_mc = widgets?.mutableCopy()
                widget_mc?.addObject(self.url)
                UD.setValue(widget_mc, forKey: "widgets")
                UD.synchronize()
            }
            else {
                let index = widgets?.indexOfObject(self.url)
                let widget_mc = widgets?.mutableCopy()
                if (index != NSNotFound) {
                    widget_mc?.removeObjectAtIndex(index!)
                }
                UD.setValue(widget_mc, forKey: "widgets")
                UD.synchronize()
            }
        }
    }
}