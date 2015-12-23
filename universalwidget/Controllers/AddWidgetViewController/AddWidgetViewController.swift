//
//  AddWidgetViewController.swift
//  universalwidget
//
//  Created by Oleg Abakumov on 14.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import Foundation
import UIKit

class AddWidgetViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView : UITableView?
    
    var itemsHref = NSMutableArray()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showStat") {
            let destinationViewController = segue.destinationViewController as! StatViewController
            var indexPath = self.tableView?.indexPathsForSelectedRows
            let title = (self.itemsHref[(indexPath?[0].row)!] as! JsonListItem).title
            
            destinationViewController.titleJSON = title
            destinationViewController.url = (self.itemsHref[(indexPath?[0].row)!] as! JsonListItem).url
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.tableFooterView = UIView()
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 44.0
        
        self.title = "Виджеты"
        
        loadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.itemsHref.count > 0) {
            let cell : StatListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! StatListTableViewCell
                    
            cell.titleItem?.text = (self.itemsHref[indexPath.row] as! JsonListItem).url
            cell.typeItem?.text = (self.itemsHref[indexPath.row] as! JsonListItem).title
            
            cell.navController = self.navigationController
            
            cell.url = (self.itemsHref[indexPath.row] as! JsonListItem).url
            
            let UD : NSUserDefaults = NSUserDefaults.init(suiteName: "group.beboss.universalwidget")!
            let widgets = UD.valueForKey("widgets") as? NSMutableArray
            
            if (widgets == nil) {
                cell.switchItem?.setOn(false, animated: true)
            }
            else {
                if (widgets!.containsObject(cell.url)) {
                    cell.switchItem?.setOn(true, animated: true)
                }
                else {
                    cell.switchItem?.setOn(false, animated: true)
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.itemsHref.count > 0) {
            return self.itemsHref.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func loadData() {
        self.itemsHref = JsonListItem.getAll()
        self.tableView?.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}