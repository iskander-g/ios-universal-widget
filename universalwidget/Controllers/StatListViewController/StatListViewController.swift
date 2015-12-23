//
//  StatListViewController.swift
//  universalwidget
//
//  Created by Oleg Abakumov on 10.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import Foundation
import UIKit

class StatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        
        self.title = "Статистика"
        
        loadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.itemsHref.count > 0) {
            let cell : StatListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! StatListTableViewCell
                        
            cell.titleItem?.text = (self.itemsHref[indexPath.row] as! JsonListItem).url
            cell.typeItem?.text = (self.itemsHref[indexPath.row] as! JsonListItem).title
            
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            let url = (self.itemsHref[indexPath.row] as! JsonListItem).url
            
            let itemFilter : NSPredicate = NSPredicate(format: "url contains[c] %@", argumentArray: [url])
            
            let itemIDs = JsonListItem.MR_findAllWithPredicate(itemFilter)
            
            (itemIDs[0] as! JsonListItem).MR_deleteEntity()
            
            NSManagedObjectContext.MR_defaultContext().MR_saveOnlySelfAndWait()
            
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 2.0);
            
            tableView.beginUpdates()
            self.itemsHref.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            
            let UD : NSUserDefaults = NSUserDefaults.init(suiteName: "group.beboss.universalwidget")!
            
            let widgets = UD.valueForKey("widgets") as? NSMutableArray
            
            let index = widgets?.indexOfObject(url)
            let widget_mc = widgets?.mutableCopy()
            if (index != NSNotFound) {
                widget_mc?.removeObjectAtIndex(index!)
            }
            UD.setValue(widget_mc, forKey: "widgets")
            UD.synchronize()
            
            tableView.endUpdates()
        }
    }
}