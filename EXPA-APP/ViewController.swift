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

    @IBOutlet weak var Label1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.Label1.text = "bbbbbbbc"
        var request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json", parameters: ["access_token":"f267b2c69766072c63ce112329fc25c76737f39dc51aea9328e7886406d1d01c"],
            success: {(response: HTTPResponse) in
                if let dict = response.responseObject as? Dictionary<String, AnyObject> {
                    self.Label1.text = "cccc"
                    
                    println("example of the JSON key: \(dict)")
                    
                    
                    
                    
                    //NSJSONSerializa
                    //println("response: \(str)")
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

