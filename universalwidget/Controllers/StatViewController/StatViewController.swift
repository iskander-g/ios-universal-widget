//
//  StatViewController.swift
//  universalwidget
//
//  Created by Oleg Abakumov on 10.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import Foundation
import UIKit

class StatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIModelDataSource {
    
    @IBOutlet var tableView : UITableView?
    
    var url : String = ""
    var titleJSON : String = ""
    
    var data : JSON?
    var model = Item()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.tableFooterView?.hidden = true
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 44.0
        
        self.title = self.titleJSON
        
        self.tableView?.tableFooterView = UIView()
        
        loadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.data?.count > 0) {
            if (self.data![indexPath.row]["value"].string == "") {
                let cell : StatTableViewHeaderCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! StatTableViewHeaderCell
                
                cell.textHeader?.text = self.data![indexPath.row]["name"].string
                
                return cell
            }
            else {
                let cell : StatTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! StatTableViewCell
                
                cell.titleText?.text = String(self.data![indexPath.row]["name"])
                cell.countText?.text = String(self.data![indexPath.row]["value"])
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.data?.count > 0) {
            return (self.data?.count)!
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func loadData() {
        self.model.url = self.url
        self.model.getJSON(self)
    }
    
    func APIModelRequestSuccess(description: AnyObject?, model: AnyObject?) {
        let desc_json = JSON(data: description as! NSData)
        self.data = desc_json["data"]
        self.tableView?.reloadData()
    }
    
    func APIModelErrorBtnTapModel(model: AnyObject?, errorController: UIViewController?) {
        errorController?.navigationController?.popViewControllerAnimated(true)
        self.loadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}