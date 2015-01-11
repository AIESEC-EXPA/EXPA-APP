//
//  MyProfileTableViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/10/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit
import SwiftHTTP

class MyProfileTableViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var full_nameOfPersonLabel: UILabel!
    @IBOutlet weak var full_nameOfCommitteeLabel: UILabel!
    @IBOutlet weak var currentPositionNameLabel: UILabel!
    @IBOutlet weak var startEndDateLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Send a HTTP request to get personal information, this will be divided to 2 steps.
        //STEP 1: get ID of current user by access token
        var ID: String?
        var request = HTTPTask()
        //TODO: access_token/refresh_token will be stored in database or a file
        let access_token = "8af2116dbb9deff995ff51c3c149575405cd4aa0e6e5b3e8f3834862e11246e0"
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json",
            parameters: ["access_token" : access_token],
            success: {(response: HTTPResponse) in
                let data1 = response.responseObject as? NSData
                if data1 == nil {
                    //TODO: pop a alert view, and do not forget the pull-down-refresh must be implemented.
                    
                } // end if data is nil
                else {
                    let json1 = JSON(data: data1!)
                    ID = json1["person"]["id"].stringValue!
                    
                    //STEP 2: get specified information that will be displayed on My Profile screen.
                    request.GET("https://gis-api.aiesec.org:443/v1/people/" + ID! + ".json",
                        parameters: ["access_token":access_token],
                        success: {(response: HTTPResponse) in
                            let data2 = response.responseObject as? NSData
                            if data2 == nil {
                                //TODO: pop a alert view, and do not forget the pull-down-refresh must be implemented.
                            }
                            else {
                                let json2 = JSON(data: data2!)
                                
                                //Display required information
                                dispatch_async(dispatch_get_main_queue(), {
                                    var profileImgURL = json2["profile_photo_urls"]["original"].stringValue!
                                    if let profileImg = NSData(contentsOfURL: NSURL(string: profileImgURL)!) {
                                        self.profileImageView.image = UIImage(data: profileImg)
                                    }
                                    //self.profileImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: profileImgURL)!)!)
                                    
                                    var gender = json2["gender"].stringValue
                                    if gender == "Male" {
                                        self.genderImageView.image = UIImage(named: "Contact_Male")
                                    }
                                    else if gender == "Female" {
                                        self.genderImageView.image = UIImage(named: "Contact_Female")
                                    }
                                    
                                    self.full_nameOfPersonLabel.text = json2["full_name"].stringValue
                                    self.full_nameOfCommitteeLabel.text = json2["current_office"]["full_name"].stringValue
                                    self.currentPositionNameLabel.text = json2["current_position"]["position_name"].stringValue
                                    self.dateOfBirthLabel.text = json2["dob"].stringValue
                                    self.introductionLabel.text = json2["introduction"].stringValue
                                    self.phoneLabel.text = json2["contact_info"]["phone"].stringValue
                                    self.emailLabel.text = json2["email"].stringValue
                                })
                            }
                        }, //end of request 2's success closure
                        failure: {(error: NSError, response: HTTPResponse?) in
                            println("failed in STEP2:\(error.description)")
                            //TODO: alert view
                    }) //end of request 2 {and failure closure}
                } // end else, if data is not nil
            }, // end of request 1's success closure
            failure: {(error: NSError, response: HTTPResponse?) in
                //TODO: pop a alert view to notify the error. If the error is that the access token is expired, refresh the token and request again.
                println("failed in STEP1: \(error.description)")
        }) // end of request 1 {and failure closure}

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }*/

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
