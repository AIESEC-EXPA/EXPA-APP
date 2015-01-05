//
//  ViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 12/30/14.
//  Copyright (c) 2014 AIESEC-EXPA. All rights reserved.
//

import UIKit

import SwiftHTTP

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json", parameters: ["access_token":"740e53727c7826245ee470e1482e45dec765308774e7a283b8a06cfbcdd39fd1"],
            success: {(response: HTTPResponse) in
                if let data = response.responseObject as? NSData {
                    let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                    //NSJSONSerializa
                    println("response: \(str)")
                }
            },
            failure: {(error: NSError, response: HTTPResponse?) in
                    println("error: \(error)")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

