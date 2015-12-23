//
//  JsonListItem.swift
//  franchising
//
//  Created by Oleg Abakumov on 01.12.14.
//  Copyright (c) 2014 Oleg Abakumov. All rights reserved.
//

import Foundation
import CoreData

@objc(JsonListItem)
class JsonListItem: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var title: String
    @NSManaged var order: Int
    @NSManaged var date_download: String
    
    class func isExist(url : String) -> Bool {
        
        let exFilter : NSPredicate = NSPredicate(format: "url contains[c] %@", argumentArray: [url])
        
        let urls : NSArray = JsonListItem.MR_findAllWithPredicate(exFilter)
        
        if(urls.count > 0) {
            return true
        }
        else {
            return false
        }
    }
    class func getAll() -> NSMutableArray {
        
        let urls : NSArray = JsonListItem.MR_findAll()
        
        return NSMutableArray(array: urls)

    }
}
