//
//  APIModel.swift
//  company
//
//  Created by Oleg Abakumov on 15.04.15.
//  Copyright (c) 2015 Oleg Abakumov. All rights reserved.
//

import Foundation

let API_MODEL_TAG : NSString = "APIModel"
let API_MODEL_HUD : NSString = "APIModelProgressHUDIdentifier"
let API_MODEL_HUD_TAG : Int = 19920912
let API_MODEL_ERR_TAG : Int = 199209120

struct StaticVariable {
    static var isWillErrorShowCounter : Bool = true
    static var pushViewController : String = "TabbarController"
    static var pushType : String = ""
    static var pushID : String = ""    
}

let queue = NSOperationQueue()
let manager = AFHTTPRequestOperationManager()

@objc protocol APIModelProtocol : NSObjectProtocol {
    func apiAction() -> NSString
}

@objc protocol APIModelDataSource : NSObjectProtocol {
    optional func APIModelRequestSuccess (description:AnyObject?, model: AnyObject?)
    optional func APIModelRequestFailed (description:AnyObject?, model: AnyObject?)
    optional func APIModelProgressBytesWritten ()
    
    optional func APIModelPreloaderWillShow (model: AnyObject?, HUD: JGProgressHUD?)
    optional func APIModelPreloaderDidShow (model: AnyObject?, HUD: JGProgressHUD?)
    optional func APIModelPreloaderWillHide (model: AnyObject?, HUD: JGProgressHUD?)
    optional func APIModelPreloaderDidHide (model: AnyObject?, HUD: JGProgressHUD?)
    
    optional func APIModelErrorWillShow (model: AnyObject?, errorController: UIViewController?)
    optional func APIModelErrorDidShow (model: AnyObject?, errorController: UIViewController?)
    optional func APIModelErrorWillHide (model: AnyObject?, errorController: UIViewController?)
    optional func APIModelErrorDidHide (model: AnyObject?, errorController: UIViewController?)
    optional func APIModelErrorBtnTapModel (model: AnyObject?, errorController: UIViewController?)
}

class APIModel : NSObject, APIModelErrorViewDelegate {
    
    var delegate : APIModelProtocol?
    var delegateSource : APIModelDataSource?
    
    //var error : NSString?
    var status : NSString?
    var server : NSString?
    var action : NSString?
    var params : NSDictionary?
    
    var isWillCachingRequest : Bool = false
    var isWillPreloaderShow : Bool = false
    
    var preloader : JGProgressHUD?
    var preloaderText : NSString = "Загрузка"
    var preloaderSubText : NSString?
    
    var errorStoryboardID : NSString = "errorViewController"
    var errorController : UIViewController?
    var isWillErrorShow : Bool = false
    
    var token : NSString?
    var mainStoryboard : UIStoryboard = UIStoryboard(name: (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) ? "Main": "MainIPAD", bundle: NSBundle.mainBundle())
    
    var isAsynchronous : Bool = false
    
    var method : String = "GET"
    
    func get(url : String, params: NSDictionary, delegateSource: AnyObject) {
        
        self.delegateSource = delegateSource as? APIModelDataSource
        
        var parameters = [String : String]()
        
        for (index, element) in params {
            let index_string = index as! String
            var element_string : String = ""
            if (element as? NSString == nil) {
                element_string = String(format: "%f", element as! Double)
            }
            else {
                element_string = element as! String
            }
            parameters[index_string] = element_string
        }
        
        let error : NSErrorPointer = NSErrorPointer()
        
        let method : String = self.method
        
        let params_get : NSMutableDictionary = NSMutableDictionary(dictionary: parameters)
        
        var request : NSMutableURLRequest?
        
        request = AFHTTPRequestSerializer().requestWithMethod(method, URLString: url, parameters: params_get, error: error)

        print(request)
        
        request?.timeoutInterval = 30
        
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/json") as Set<NSObject>
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let requestOperation : AFHTTPRequestOperation = manager.HTTPRequestOperationWithRequest(
            request!,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                self.delegateSource?.APIModelRequestSuccess!(responseObject, model: self.delegate)
                if (self.isWillPreloaderShow) {
                    self.preloaderHide()
                }
                self.errorController = nil
            },
            failure : { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
                if (self.isWillPreloaderShow) {
                    self.preloaderHide()
                }
                self.errorShow()
            }
        )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleOperationDidStart:"), name: AFNetworkingOperationDidStartNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleOperationDidFinish:"), name: AFNetworkingOperationDidFinishNotification, object: nil)
        
        if (self.isAsynchronous) {
            NSOperationQueue.mainQueue().addOperation(requestOperation)
        }
        else {
            queue.addOperation(requestOperation)
        }
    }
    
    func preloaderShow() {
        if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelPreloaderWillShow:errorController:")) == true) {
            self.delegateSource?.APIModelPreloaderWillShow!(delegate, HUD: preloader)
        }
        
        if (isWillPreloaderShow) {
            if (self.delegate != nil && self.delegateSource?.isKindOfClass(UIViewController) != false) {
                let view : UIView? = self.getViewControllerFromDelegateData()?.view
                self.preloader = view?.viewWithTag(API_MODEL_HUD_TAG) as? JGProgressHUD
                if (self.preloader == nil) {
                    self.preloader = JGProgressHUD(style: JGProgressHUDStyle.Dark)
                    self.preloader?.tag = API_MODEL_HUD_TAG
                    self.preloader?.backgroundColor = UIColor(red:CGFloat(0), green:CGFloat(0), blue: CGFloat(0), alpha: CGFloat(0.15))
                    let frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
                    self.preloader?.frame = frame
                    self.preloader?.position = JGProgressHUDPosition.Center
                }
                self.preloader?.textLabel.text = self.preloaderText as String
                if (view?.viewWithTag(API_MODEL_HUD_TAG) == nil) {
                    self.preloader?.showInView(view)
                    if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelPreloaderDidShow:errorController:")) != false) {
                        self.delegateSource?.APIModelPreloaderDidShow!(self.delegate, HUD: self.preloader)
                    }
                }
            }
        }
    }
    
    func preloaderHide() {
        if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelPreloaderWillHide:errorController:")) != false) {
            self.delegateSource?.APIModelPreloaderWillHide!(self.delegate, HUD: self.preloader)
        }
        if (self.preloader != nil) {
            let view : UIView? = self.getViewControllerFromDelegateData()?.view
            self.preloader = view?.viewWithTag(API_MODEL_HUD_TAG) as? JGProgressHUD
            self.preloader?.dismiss()
            if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelPreloaderDidHide:errorController:")) != false) {
                self.delegateSource?.APIModelPreloaderDidHide!(self.delegate, HUD: self.preloader)
            }
        }
    }
    
    func getViewControllerFromDelegateData() -> UIViewController? {
        if(self.delegateSource != nil && self.delegateSource?.isKindOfClass(UIViewController) != false) {
            return self.delegateSource as! NSObjectProtocol as! NSObject as? UIViewController
        }
        
        return nil
    }
    
    func errorShow () {
        if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelErrorWillShow:errorController:")) != false) {
            self.delegateSource?.APIModelErrorWillShow!(self.delegate, errorController: self.errorController)
        }
        if (self.isWillErrorShow) {
            if (self.errorController == nil) {
                self.errorController = self.mainStoryboard.instantiateViewControllerWithIdentifier(self.errorStoryboardID as String) as! ErrorViewController
            }
            let amev = self.errorController as! APIModelErrorViewController
            amev.delegate = self
            
            if (StaticVariable.isWillErrorShowCounter) {
                StaticVariable.isWillErrorShowCounter = false
                if (self.getViewControllerFromDelegateData()?.navigationController?.pushViewController(self.errorController!, animated: true) == nil) {
                    self.getViewControllerFromDelegateData()?.navigationController?.pushViewController(self.errorController!, animated: true)
                    StaticVariable.isWillErrorShowCounter = true
                }
            }
        }
    }
    
    func errorHide () {
        if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelErrorWillHide:errorController:")) != false) {
            self.delegateSource?.APIModelErrorWillHide!(self.delegate, errorController: self.errorController)
        }
        if (self.isWillErrorShow) {
            self.getViewControllerFromDelegateData()?.navigationController?.popToRootViewControllerAnimated(true)
            
            if (self.delegateSource != nil && self.delegateSource?.respondsToSelector(Selector("APIModelErrorDidHide:errorController:")) != false) {
                self.delegateSource?.APIModelErrorDidHide!(self.delegate, errorController: self.errorController)
            }
        }
    }
    
    func handleOperationDidStart (notif: NSNotification) {
        if(queue.operationCount != 0) {
            if (self.isWillPreloaderShow) {
                self.preloaderShow()
            }
        }
    }
    
    func handleOperationDidFinish (notif: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func errorBtnTap(sender: AnyObject, controller: AnyObject) {
        if (self.delegateSource?.respondsToSelector("APIModelErrorBtnTapModel:errorController:") == true) {
            self.delegateSource?.APIModelErrorBtnTapModel!(self.delegate, errorController: self.errorController)
        }
    }
    
}
