//
//  AddStatViewController.swift
//  universalwidget
//
//  Created by Oleg Abakumov on 10.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import Foundation
import UIKit

class AddStatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, APIModelDataSource {
    
    @IBOutlet var tableView : UITableView?
    
    var data : JSON?
    var model = Item()
    
    var url : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.tableFooterView?.hidden = true
        self.tableView?.tableFooterView = UIView()
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 44.0
        
        self.title = "Добавить JSON"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : AddStatTableViewCell = tableView.dequeueReusableCellWithIdentifier("AddCell", forIndexPath: indexPath) as! AddStatTableViewCell
        
        cell.searchURL?.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (JsonListItem.isExist(textField.text!)) {
            
            PKHUD.sharedHUD.contentView = PKHUDErrorView()
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 2.0);
        }
        else {
            self.url = textField.text!
            
            self.loadData()
            
            textField.text = ""
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func loadData() {
        self.model.url = self.url
        self.model.getJSON(self)
    }
    
    func APIModelRequestSuccess(description: AnyObject?, model: AnyObject?) {
        let desc_json = JSON(data: description as! NSData)
        self.data = desc_json["data"]
        print(desc_json["title"])
        
        let new_item : JsonListItem = JsonListItem.MR_createEntity() as! JsonListItem
        
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        new_item.date_download = dateFormatter.stringFromDate(todaysDate)
        
        new_item.url = self.url
        new_item.title = desc_json["title"].stringValue
        
        NSManagedObjectContext.MR_defaultContext().MR_saveOnlySelfAndWait()
        
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 2.0);
    }
}