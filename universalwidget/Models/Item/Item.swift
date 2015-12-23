//
//  Item.swift
//  universalwidget
//
//  Created by Oleg Abakumov on 10.12.15.
//  Copyright © 2015 beboss. All rights reserved.
//

import Foundation

class Item: APIModel, APIModelProtocol {
    var url : String?
    
    override init() {
        super.init()
        self.delegate = self
        self.isWillPreloaderShow = true
    }
    
    func apiAction() -> NSString {
        return ""
    }
    
    func getJSON(delegateSource: AnyObject) {
        self.get(url!, params: [:], delegateSource: delegateSource)
    }
}