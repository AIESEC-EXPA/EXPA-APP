//
//  test.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/5/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import Foundation
import SwiftHTTP

func requestUrl(urlString: String){
    var url: NSURL = NSURL(string: urlString)!
    let request: NSURLRequest = NSURLRequest(URL: url)
    
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{
        (response, data, error) -> Void in
        
        if (error != nil) {
            //Handle Error here
        }else{
            //Handle data in NSData type
            
        }
        
    })
}