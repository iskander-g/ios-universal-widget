//
//  JsonAddController.swift
//  universalwidget
//
//  Created by Искандер on 22.06.15.
//  Copyright (c) 2015 beboss. All rights reserved.
//

import UIKit
import Foundation

class JsonAddController: UIViewController {

    @IBOutlet weak var textJsonUrl: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelJsonTitle: UILabel!
    @IBOutlet weak var buttonAdd: UIButton!
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    @IBAction func urlTextEditingChanged(sender: AnyObject) {
        labelJsonTitle.hidden = true
        buttonAdd.hidden = true
    }
    @IBAction func CheckButtonTap(sender: UIButton) {
        if textJsonUrl.text?.characters.count > 0 {
            
            let URL = NSURL(string: textJsonUrl.text!)
            let task = session.dataTaskWithURL(URL!) {
                data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    
                    do {
                        var jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.progressIndicator.stopAnimating();
                        })
                        
                        var title:String  = jsonResult["title"] as! String
                        if title.characters.count > 0 {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.labelJsonTitle.text = title
                                self.labelJsonTitle.hidden = false
                                self.buttonAdd.hidden = false
                                self.buttonAdd.enabled = true
                            })

                        }
                    }
                    catch {
                    
                    }

                }
            }
            progressIndicator.startAnimating();
            task.resume()
            
        }
    }
    @IBAction func addButtonTap(sender: UIButton) {
        
        var JsonItem = JsonListItem()
        
        JsonItem.title = labelJsonTitle.text!
        JsonItem.url = textJsonUrl.text!
        JsonItem.date_download = NSTimeInterval()
        JsonItem.order = 1
        
        CoreDataHelper.instance.save()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
