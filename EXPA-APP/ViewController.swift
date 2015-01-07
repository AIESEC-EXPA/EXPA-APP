//
//  ViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 12/30/14.
//  Copyright (c) 2014 AIESEC-EXPA. All rights reserved.
//

import UIKit

import SwiftHTTP
//import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var textview1: UITextView!
    @IBOutlet weak var Label1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.Label1.text = "bbbbbbbc"
        var request = HTTPTask()
        //request.responseSerializer = JSONResponseSerializer()
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json", parameters: ["access_token":"227e41b622d9418c695000680c7c343d1e33403bfe388792692cc25cdec7d2fc"],
            success: {(response: HTTPResponse) in
                if let data = response.responseObject as? NSData {
                    let json = JSON(data: data)
                    println(json["person"]["email"])
                    dispatch_async(dispatch_get_main_queue(), {
                        self.Label1.text = json["person"]["email"].stringValue
                        self.textview1.text = NSString(data: data, encoding: NSUTF8StringEncoding)
                    })
                }
            },
            failure: {(error: NSError, response: HTTPResponse?) in
                    println("error: \(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.Label1.text = error.description
                })
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

