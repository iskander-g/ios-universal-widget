//
//  JsonListItem.swift
//  universalwidget
//
//  Created by Искандер on 22.06.15.
//  Copyright (c) 2015 beboss. All rights reserved.
//

import Foundation
import CoreData

@objc(JsonListItem)
class JsonListItem: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var date_download: NSTimeInterval
    @NSManaged var order: Int16
    @NSManaged var title: String
    
    class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("JsonListItem", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: JsonListItem.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
        
    }
    
    class func AllJsonListItems() -> [JsonListItem] {
        let request = NSFetchRequest(entityName: "JsonListItem")
        
        do {
            let results = try CoreDataHelper.instance.context.executeFetchRequest(request)
            
            return results as! [JsonListItem]
        }
        catch {
            return []
        }
    
    }

}
