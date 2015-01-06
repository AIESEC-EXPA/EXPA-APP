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

    @IBOutlet weak var Label1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.Label1.text = "bbbbbbbc"
        var request = HTTPTask()
        //request.responseSerializer = JSONResponseSerializer()
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json", parameters: ["access_token":"431b9c8e5d9fb6a2e0470f9010111aa7f356f81ad5dbd71e3904574b76339ecd"],
            success: {(response: HTTPResponse) in
                if let data = response.responseObject as? NSData {
                    let json = JSON(data: data)
                    println(json["person"]["email"])
                    dispatch_async(dispatch_get_main_queue(), {
                        self.Label1.text = json["person"]["email"].stringValue
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

