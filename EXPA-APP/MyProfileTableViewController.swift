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
    @IBOutlet weak var createdUpdateDateLabel: UILabel!
    @IBOutlet weak var introductioinTableCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Send a HTTP request to get personal information, this will be divided to 2 steps.
        //STEP 1: get ID of current user by access token
        var ID: String?
        var request = HTTPTask()
        //TODO: access_token/refresh_token will be stored in database or a file
        let access_token = "84753eeda8cab437d19ef88443fbdaef741beb224b1ca6cf0f9e4c8ed8b0f44e"
        
        if let IDinStorage = Tools.getFromInfo_plist(forKey: "user_ID") {
            let documentsFolder = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
            let path = documentsFolder.stringByAppendingPathComponent("EXPA.sqlite")
            
            let database = FMDatabase(path: path)
            
            if !database.open() {
                println("database open failed: \(database.lastErrorMessage())")
            }
            else {
                if let d = database.executeQuery("SELECT * FROM persons WHERE ID=?", IDinStorage) {
                    d.next()
                    var pathOfProfileImage = documentsFolder.stringByAppendingPathComponent("profileImage/\(IDinStorage).jpg")
                    if let img = NSData(contentsOfFile: pathOfProfileImage) {
                        self.profileImageView.image = UIImage(data: img)
                    }
                    
                    var gender = d.stringForColumn("gender")
                    if gender == "Male" {
                        self.genderImageView.image = UIImage(named: "Contact_Male")
                    }
                    else if gender == "Female" {
                        self.genderImageView.image = UIImage(named: "Contact_Female")
                    }
                    
                    self.full_nameOfPersonLabel.text = d.stringForColumn("full_name")
                    self.full_nameOfCommitteeLabel.text = d.stringForColumn("current_committee_name")
                    self.currentPositionNameLabel.text = d.stringForColumn("current_position_name")
                    self.startEndDateLabel.text = Tools.oneDateToAnotherDate(oneDate: d.stringForColumn("start_date"), anotherDate: d.stringForColumn("end_date"))
                    self.dateOfBirthLabel.text = d.stringForColumn("dob")
                    
                    if d.stringForColumn("introduction") == "None" {
                        self.introductionLabel.text = "None"
                        self.introductionLabel.textColor = UIColor.lightGrayColor()
                        self.introductioinTableCell.accessoryType = UITableViewCellAccessoryType.None
                        self.introductioinTableCell.userInteractionEnabled = false
                    }
                    else {
                        self.introductionLabel.text = d.stringForColumn("introduction")
                        self.introductionLabel.textColor = UIColor.blackColor()
                        self.introductioinTableCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                        self.introductioinTableCell.userInteractionEnabled = true
                    }
                    
                    self.phoneLabel.text = d.stringForColumn("phone")
                    self.emailLabel.text = d.stringForColumn("email")
                    
                    var createdDate = Tools.convertRFC3339ToNSDate(RFC3339String: d.stringForColumn("created_at"))
                    var updatedDate = Tools.convertRFC3339ToNSDate(RFC3339String: d.stringForColumn("updated_at"))
                    var formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.createdUpdateDateLabel.text = "Created At \(formatter.stringFromDate(createdDate!)) | Updated At \(formatter.stringFromDate(updatedDate!))"
                }
            }
        }
        
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json",
            parameters: ["access_token" : access_token],
            success: {(response: HTTPResponse) in
                if let data1 = response.responseObject as? NSData {
                    let json1 = JSON(data: data1)
                    ID = json1["person"]["id"].stringValue!
                    
                    //STEP 2: get specified information that will be displayed on My Profile screen.
                    request.GET("https://gis-api.aiesec.org:443/v1/people/\(ID!).json",
                        parameters: ["access_token":access_token],
                        success: {(response: HTTPResponse) in
                            if let data2 = response.responseObject as? NSData
                            {
                                let json2 = JSON(data: data2)
                                
                                //Display required information
                                dispatch_async(dispatch_get_main_queue(), {
                                    let documentsFolder = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
                                    
                                    var profileImgURL = json2["profile_photo_urls"]["original"].stringValue!
                                    if let profileImg = NSData(contentsOfURL: NSURL(string: profileImgURL)!) {
                                        self.profileImageView.image = UIImage(data: profileImg)
                                        var path = documentsFolder.stringByAppendingPathComponent("profileImage")
                                        var error: NSError?
                                        if !NSFileManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error) {
                                            if let e = error {
                                                println("create dir failed: \(e.description)")
                                            }
                                        }
                                        path = documentsFolder.stringByAppendingPathComponent("profileImage/\(ID!).jpg")
                                        if !UIImageJPEGRepresentation(self.profileImageView.image, 1).writeToFile(path, options: nil, error: &error) {
                                            if let e = error {
                                                println("profileImage save failed:\(e.description)")
                                            }
                                        }
                                    }
                                    
                                    var gender = json2["gender"].stringValue
                                    if gender == "Male" {
                                        self.genderImageView.image = UIImage(named: "Contact_Male")
                                    }
                                    else if gender == "Female" {
                                        self.genderImageView.image = UIImage(named: "Contact_Female")
                                    }
                                    
                                    self.full_nameOfPersonLabel.text = json2["full_name"].stringValue
                                    self.full_nameOfCommitteeLabel.text = json2["current_office"]["full_name"].stringValue
                                    self.currentPositionNameLabel.text = json1["current_position"]["position_name"].stringValue
                                    self.startEndDateLabel.text = Tools.oneDateToAnotherDate(oneDate: json1["current_position"]["start_date"].stringValue!, anotherDate: json1["current_position"]["end_date"].stringValue!)
                                    self.dateOfBirthLabel.text = json2["dob"].stringValue
                                    
                                    if json2["introduction"].stringValue == nil {
                                        self.introductionLabel.text = "None"
                                        self.introductionLabel.textColor = UIColor.lightGrayColor()
                                        self.introductioinTableCell.accessoryType = UITableViewCellAccessoryType.None
                                        self.introductioinTableCell.userInteractionEnabled = false
                                    }
                                    else {
                                        self.introductionLabel.text = json2["introduction"].stringValue
                                        self.introductionLabel.textColor = UIColor.blackColor()
                                    }
                                    
                                    self.phoneLabel.text = json2["contact_info"]["phone"].stringValue
                                    self.emailLabel.text = json2["email"].stringValue
                                    
                                    //TODO: all positions
                                    
                                    //Assemble the createdUpdatedDateLabel
                                    var createdDate = Tools.convertRFC3339ToNSDate(RFC3339String: json2["created_at"].stringValue!)
                                    var updatedDate = Tools.convertRFC3339ToNSDate(RFC3339String: json2["updated_at"].stringValue!)
                                    var formatter = NSDateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    self.createdUpdateDateLabel.text = "Created At \(formatter.stringFromDate(createdDate!)) | Updated At \(formatter.stringFromDate(updatedDate!))"
                                    
                                    //save to sqlite
                                    var path = documentsFolder.stringByAppendingPathComponent("EXPA.sqlite")
                                    println(path)
                                    let database = FMDatabase(path: path)
                                    
                                    if !database.open() {
                                        println("database open failed:\(database.lastErrorMessage())")
                                    }
                                    else {
                                        //create table if not exists
                                        var query = "CREATE TABLE IF NOT EXISTS persons(ID INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, full_name TEXT, dob TEXT, introduction TEXT, gender TEXT, email TEXT, phone TEXT, current_position_name TEXT, current_committee_name TEXT, start_date TEXT, end_date TEXT, created_at TEXT, updated_at TEXT)"
                                        if !database.executeUpdate(query, withArgumentsInArray: nil) {
                                            println("database open failed:\(database.lastErrorMessage())")
                                        }
                                        
                                        query = "DELETE FROM persons WHERE ID=?"
                                        database.executeUpdate(query, ID!)
                                        
                                        //insert
                                        query = "INSERT INTO persons(ID, first_name, last_name, full_name, dob, introduction, gender, email, phone, current_position_name, current_committee_name, start_date, end_date, created_at, updated_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
                                        if !database.executeUpdate(query, ID!, json2["first_name"].stringValue!, json2["last_name"].stringValue!, json2["full_name"].stringValue!, json2["dob"].stringValue!, self.introductionLabel.text!, json2["gender"].stringValue!, json2["email"].stringValue!, json2["contact_info"]["phone"].stringValue!, json2["email"].stringValue!, json1["current_position"]["position_name"].stringValue!, json2["current_office"]["full_name"].stringValue!, json1["current_position"]["start_date"].stringValue!, json1["current_position"]["end_date"].stringValue!, json2["created_at"].stringValue!, json2["updated_at"].stringValue!) {
                                            println("insert failed: \(database.lastErrorMessage())")
                                        }
                                    }
                                    
                                }) //end of dispatch main queue
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if sender as? UITableViewCell == self.introductioinTableCell {
            var dest = segue.destinationViewController as IntroductionViewController
            dest.introductionText = introductionLabel.text
        }
        
    }
    

}
