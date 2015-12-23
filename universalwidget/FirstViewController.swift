//
//  FirstViewController.swift
//  universalwidget
//
//  Created by Искандер on 22.06.15.
//  Copyright (c) 2015 beboss. All rights reserved.
//

import UIKit
import Foundation

class jsonParsedData {
    var type: String?
    var name: String?
    var value: String?
}


class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var DataTableView: UITableView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    var jsonItems: [jsonParsedData]?
    var jsonUrlsItems: [JsonListItem]?
    var isUpdating: Bool?
    var currentJsonUrlIndex: Int?
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    @IBAction func refreshButtonTap(sender: AnyObject) {
        jsonUrlsItems = JsonListItem.AllJsonListItems()
        
        self.jsonItems = [];
        
        if !isUpdating!  {
            currentJsonUrlIndex = 0;
            if(jsonUrlsItems!.count > 0) {
                loadJsonFromUrlByIndex(currentJsonUrlIndex!)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jsonUrlsItems = JsonListItem.AllJsonListItems()
        self.jsonItems = [];
        
        isUpdating = true
        currentJsonUrlIndex = 0;
        if(jsonUrlsItems!.count > 0) {
            loadJsonFromUrlByIndex(currentJsonUrlIndex!)
        }
        DataTableView.delegate = self
        DataTableView.dataSource = self
        DataTableView.tableFooterView = UIView();

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        
    }
    
    func loadJsonFromUrlByIndex(index: Int) {

        ActivityIndicator.startAnimating()
        

        let URL = NSURL(string: jsonUrlsItems![index].url)
        let task = session.dataTaskWithURL(URL!) {
            data, response, error in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                do {
                
                    var jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.ActivityIndicator.stopAnimating();
                    })
                    
                    var title:String  = jsonResult["title"] as! String

                    if title.characters.count > 0 {
                        var tmp = jsonParsedData()
                        tmp.type = "header"
                        tmp.name = title
                        self.jsonItems?.append(tmp)
                    }
                    
                    var data:Array = jsonResult["data"] as! Array<AnyObject>;
                    for item in data {

                        var tmp = jsonParsedData()
                        tmp.type = "data"
                        tmp.value = item["value"] as? String
                        tmp.name = item["name"] as? String
                        

                        self.jsonItems?.append(tmp)
                        
                    }
                    
                    

                    self.currentJsonUrlIndex = self.currentJsonUrlIndex! + 1
                    if self.currentJsonUrlIndex! < self.jsonUrlsItems!.count {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.loadJsonFromUrlByIndex(self.currentJsonUrlIndex!)
                        })
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.isUpdating = false
                            self.DataTableView.reloadData()
                        })
                    }
                }
                catch {
                
                }
                
            }
        }
        task.resume()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonItems!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(jsonItems![indexPath.row].type == "header") {
            var tmpCell = self.DataTableView.dequeueReusableCellWithIdentifier("JsonHeaderCell") as! JsonDataHeaderCell
            tmpCell.labelHeader.text = jsonItems![indexPath.row].name
            return tmpCell
        } else {
            var tmpCell = self.DataTableView.dequeueReusableCellWithIdentifier("DataCell") as! JsonDataCell
            tmpCell.labelTitle.text = jsonItems![indexPath.row].name
            tmpCell.labelData.text = jsonItems![indexPath.row].value
            return tmpCell
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

