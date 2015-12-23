//
//  SecondViewController.swift
//  universalwidget
//
//  Created by Искандер on 22.06.15.
//  Copyright (c) 2015 beboss. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var JsonTableItems: UITableView!
    var jsonItems: [JsonListItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JsonTableItems.delegate = self
        JsonTableItems.dataSource = self
        JsonTableItems.tableFooterView = UIView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        JsonTableItems.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        jsonItems = JsonListItem.AllJsonListItems()
        
        return jsonItems!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = JsonTableItems.dequeueReusableCellWithIdentifier("JsonListCell") as! JsonListCell
        cell.labelTitle.text = jsonItems![indexPath.row].title
        cell.labelUrl.text = jsonItems![indexPath.row].url
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            CoreDataHelper.instance.context.deleteObject(jsonItems![indexPath.row])
            JsonTableItems.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            CoreDataHelper.instance.save()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

