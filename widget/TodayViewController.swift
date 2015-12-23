//
//  TodayViewController.swift
//  widget
//
//  Created by Oleg Abakumov on 11.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
    
    @IBOutlet var tableView : UITableView?
    
    var url : String = ""
    var data : JSON?
    
    var titleJSON : String = ""
    
    let queue = NSOperationQueue()
    let manager = AFHTTPRequestOperationManager()
    
    let method = "GET"
    
    let UD : NSUserDefaults = NSUserDefaults.init(suiteName: "group.beboss.universalwidget")!
    let UDStandard : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var cachedItems : JSON {
        get {
            let desc_json = JSON(data: (self.UDStandard.objectForKey("data") as? NSData)!)
            return desc_json["data"]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        if (self.UDStandard.objectForKey("data") as? NSData != nil) {
            self.data = self.cachedItems
        }
        
        if (self.UDStandard.objectForKey("title") as? String != nil) {
            self.titleJSON = self.UDStandard.objectForKey("title") as! String
        }
        
        let widgets = self.UD.valueForKey("widgets") as? NSMutableArray
        if (widgets != nil && widgets![0] as? String != nil) {
            
            self.url = widgets![0] as! String
            
            self.loadData()
            
            let taskManager = NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: "loadData", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(taskManager, forMode: NSRunLoopCommonModes)
            
        }
        
        self.tableView?.tableFooterView?.hidden = true
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 44.0
        
        self.tableView?.tableFooterView = UIView()
        
        updatePreferredContentSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        self.loadData()
        completionHandler(NCUpdateResult.NewData)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            self.preferredContentSize = (self.tableView?.contentSize)!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.data?.count > 0) {
            if (indexPath.row == 0) {
                let cell : StatTableUpdateCell = tableView.dequeueReusableCellWithIdentifier("UpdateCell", forIndexPath: indexPath) as! StatTableUpdateCell
                                
                if (self.titleJSON == "") {
                    cell.titleCell?.text = self.UDStandard.objectForKey("title") as? String
                }
                else {
                    cell.titleCell?.text = self.titleJSON
                }
                
                let date = (self.UDStandard.valueForKey("date") as! NSDate)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                
                cell.dateCell?.text = String (format: "Обновлено %@", arguments: [dateFormatter.stringFromDate(date)])
                
                return cell
            }
            if (self.data![indexPath.row - 1]["value"].string == "") {
                let cell : StatTableViewHeaderCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! StatTableViewHeaderCell
                
                cell.textHeader?.text = self.data![indexPath.row - 1]["name"].string
                
                return cell
            }
            else {
                let cell : StatTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! StatTableViewCell
                
                cell.titleText?.text = String(self.data![indexPath.row - 1]["name"])
                cell.countText?.text = String(self.data![indexPath.row - 1]["value"])
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.data?.count > 0) {
            return (self.data?.count)! + 1
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
            return UIEdgeInsetsZero
    }
    
    func updatePreferredContentSize() {
        self.tableView?.reloadData()
        self.preferredContentSize = (self.tableView?.contentSize)!
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
    func loadData() {
        
        let error : NSErrorPointer = NSErrorPointer()
        
        let method : String = self.method
        
        var request : NSMutableURLRequest?
        
        request = AFHTTPRequestSerializer().requestWithMethod(method, URLString: self.url, parameters: nil, error: error)
        
        print(request)
        
        request?.timeoutInterval = 30
        
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html") as Set<NSObject>
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let requestOperation : AFHTTPRequestOperation = manager.HTTPRequestOperationWithRequest(
            request!,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                let desc_json = JSON(data: responseObject as! NSData)
                
                self.UDStandard.setValue(NSDate(), forKey: "date")
                self.UDStandard.synchronize()
                
                if (self.data?.count > 0) {
                    self.tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                if (self.hasNewData(desc_json["data"])) {
                
                    self.data = desc_json["data"]
                    self.titleJSON = desc_json["title"].stringValue
                    
                    self.updatePreferredContentSize()

                    self.UDStandard.setValue(responseObject, forKey: "data")
                    self.UDStandard.setValue(self.titleJSON, forKey: "title")
                    
                    self.UDStandard.synchronize()
                }
                else {
                    
                }
            },
            failure : { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
            }
        )
        
        queue.addOperation(requestOperation)
    }
    
    func hasNewData(feedItems: JSON?) -> Bool {
        return self.data == nil || self.data != feedItems
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == 0) {
            self.loadData()
        }
        else {
            self.extensionContext?.openURL(NSURL(string: "universalwidget://")!, completionHandler: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
