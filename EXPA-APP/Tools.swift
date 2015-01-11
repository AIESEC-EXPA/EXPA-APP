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
}

