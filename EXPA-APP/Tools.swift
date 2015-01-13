//
//  Tools.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/11/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import Foundation
import SwiftHTTP

class Tools {
    class func refreshTokenAndGET(#URL: String, token: String, parameters: Dictionary<String, AnyObject>?, failure: ((NSError, HTTPResponse?) -> Void)! ) -> HTTPResponse?
    {
        var request = HTTPTask()
        var Response: HTTPResponse?
        request.GET(URL, parameters: parameters, success: {(response: HTTPResponse) in
            Response = response
            },
            failure: {(error: NSError, response: HTTPResponse?) in
            //TODO: if access token is expired, refresh it and request again
        })
        return Response
    }
    
    //Convert RFC3339 datetime string to NSDate object
    class func convertRFC3339ToNSDate(#RFC3339String: String) -> NSDate? {
        var RFC3339dateformatter = NSDateFormatter()
        RFC3339dateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        RFC3339dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        RFC3339dateformatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        var date = RFC3339dateformatter.dateFromString(RFC3339String)
        return date?
    }
    
    class func oneDateToAnotherDate(#oneDate: String, anotherDate: String) -> String {
        var date1 = convertRFC3339ToNSDate(RFC3339String: oneDate)
        var date2 = convertRFC3339ToNSDate(RFC3339String: anotherDate)
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(date1!) + " ~ " + formatter.stringFromDate(date2!)
    }
    
    class func getFromInfo_plist(#forKey: String) -> String? {
        var File = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        var dict = NSMutableDictionary(contentsOfFile: File!)
        var str = dict?.objectForKey(forKey) as? String
        return str
    }
    
    class func saveToInfo_plist(#forKey: String, value: AnyObject) -> Void {
        var File = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        var dict = NSMutableDictionary(contentsOfFile: File!)
        dict?.setObject("ddddddd", forKey: "access_token")
        dict?.writeToFile(File!, atomically: true)
    }
    
    //class func SQLiteExecuteUpdate(#sqliteFileName: String, #tableName: String, #query: String
}

