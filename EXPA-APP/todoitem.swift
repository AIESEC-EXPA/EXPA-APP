//
//  todoitem.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/7/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit

class todoitem: NSObject {
    var itemname:NSString
    var completed:Bool
    let creationdate:NSDate
    
    init(name: String)
    {
        itemname = name
        completed = false
        creationdate = NSDate()
    }
}
