//
//  MyProfileTableViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/10/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit
import SwiftHTTP

class MyProfileTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var ID: String?
    var programmesDataResource: NSMutableArray?

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
    @IBOutlet weak var seemoreTableCell: UITableViewCell!
    @IBOutlet weak var seemoreLabel: UILabel!
    @IBOutlet weak var programmesCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        //Send a HTTP request to get personal information, this will be divided to 2 steps.
        //STEP 1: get ID of current user by access token
        
        var request = HTTPTask()
        //TODO: access_token/refresh_token will be stored in database or a file
        let access_token = "11bd9be64252aabc9f77144f10f298e1d140d466eb436ca8f45c02a9d06aa915"
        
        if let IDinStorage = Tools.getFromInfo_plist(forKey: "user_ID") {
            self.ID = IDinStorage
            
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
                    
                    self.seemoreLabel.textColor = UIColor.blackColor()
                    self.seemoreTableCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    self.seemoreTableCell.userInteractionEnabled = true
                }
                if let da = database.executeQuery("SELECT * FROM programmes WHERE user_ID=?", IDinStorage) {
                    var array = NSMutableArray()
                    while da.next() {
                        array.addObject(da.stringForColumn("programme_id"))
                    }
                    self.programmesDataResource = array
                    self.programmesCollectionView.reloadData()
                }
            }
            database.close()
        }
        
        request.GET("https://gis-api.aiesec.org:443/v1/current_person.json",
            parameters: ["access_token" : access_token],
            success: {(response: HTTPResponse) in
                if let data1 = response.responseObject as? NSData {
                    let json1 = JSON(data: data1)
                    self.ID = json1["person"]["id"].stringValue
                    
                    //STEP 2: get specified information that will be displayed on My Profile screen.
                    request.GET("https://gis-api.aiesec.org:443/v1/people/\(self.ID!).json",
                        parameters: ["access_token":access_token],
                        success: {(response: HTTPResponse) in
                            if let data2 = response.responseObject as? NSData
                            {
                                let json2 = JSON(data: data2)
                                
                                //Display required information
                                dispatch_async(dispatch_get_main_queue(), {
                                    let documentsFolder = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
                                    
                                    var profileImgURL = json2["profile_photo_urls"]["original"].stringValue
                                    if let profileImg = NSData(contentsOfURL: NSURL(string: profileImgURL)!) {
                                        self.profileImageView.image = UIImage(data: profileImg)
                                        var path = documentsFolder.stringByAppendingPathComponent("profileImage")
                                        var error: NSError?
                                        if !NSFileManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error) {
                                            if let e = error {
                                                println("create dir failed: \(e.description)")
                                            }
                                        }
                                        path = documentsFolder.stringByAppendingPathComponent("profileImage/\(self.ID!).jpg")
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
                                    self.startEndDateLabel.text = Tools.oneDateToAnotherDate(oneDate: json1["current_position"]["start_date"].stringValue, anotherDate: json1["current_position"]["end_date"].stringValue)
                                    self.dateOfBirthLabel.text = json2["dob"].stringValue
                                    
                                    if json2["introduction"].stringValue == "" {
                                        self.introductionLabel.text = "None"
                                        self.introductionLabel.textColor = UIColor.lightGrayColor()
                                        self.introductioinTableCell.accessoryType = UITableViewCellAccessoryType.None
                                        self.introductioinTableCell.userInteractionEnabled = false
                                    }
                                    else {
                                        self.introductionLabel.text = json2["introduction"].stringValue
                                        self.introductionLabel.textColor = UIColor.blackColor()
                                        self.introductioinTableCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                        self.introductioinTableCell.userInteractionEnabled = true
                                    }
                                    
                                    self.phoneLabel.text = json2["contact_info"]["phone"].stringValue
                                    self.emailLabel.text = json2["email"].stringValue
                                    
                                    
                                    //Assemble the createdUpdatedDateLabel
                                    var createdDate = Tools.convertRFC3339ToNSDate(RFC3339String: json2["created_at"].stringValue)
                                    var updatedDate = Tools.convertRFC3339ToNSDate(RFC3339String: json2["updated_at"].stringValue)
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
                                        //create persons' table if not exists
                                        var query = "CREATE TABLE IF NOT EXISTS persons(ID INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, full_name TEXT, dob TEXT, introduction TEXT, gender TEXT, email TEXT, phone TEXT, current_position_name TEXT, current_committee_name TEXT, start_date TEXT, end_date TEXT, created_at TEXT, updated_at TEXT)"
                                        if !database.executeUpdate(query, withArgumentsInArray: nil) {
                                            println("database persons create failed:\(database.lastErrorMessage())")
                                        }
                                        
                                        query = "DELETE FROM persons WHERE ID=?"
                                        database.executeUpdate(query, self.ID!)
                                        
                                        //insert into persons' table
                                        query = "INSERT INTO persons(ID, first_name, last_name, full_name, dob, introduction, gender, email, phone, current_position_name, current_committee_name, start_date, end_date, created_at, updated_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
                                        if !database.executeUpdate(query, self.ID!, json2["first_name"].stringValue, json2["last_name"].stringValue, self.full_nameOfPersonLabel.text!, self.dateOfBirthLabel.text!, self.introductionLabel.text!, gender, self.emailLabel.text!, self.phoneLabel.text!, self.currentPositionNameLabel.text!, self.full_nameOfCommitteeLabel.text!, json1["current_position"]["start_date"].stringValue, json1["current_position"]["end_date"].stringValue, json2["created_at"].stringValue, json2["updated_at"].stringValue) {
                                            println("insert persons failed: \(database.lastErrorMessage())")
                                        }
                                        
                                        // create positions' table is not exists
                                        query = "CREATE TABLE IF NOT EXISTS positions(user_ID INTEGER, position_ID INTEGER PRIMARY KEY, position_name TEXT, start_date TEXT, end_date TEXT, team_ID INTEGER, team_title TEXT)"
                                        if !database.executeUpdate(query) {
                                            println("database positions create failed:\(database.lastErrorMessage())")
                                        }
                                        
                                        query = "DELETE FROM positions WHERE user_ID=?"
                                        database.executeUpdate(query, self.ID!)
                                        
                                        //insert into positions' table
                                        query = "INSERT INTO positions(user_ID, position_ID, position_name, start_date, end_date, team_ID, team_title) VALUES(?,?,?,?,?,?,?)"
                                        
                                        var positions = json2["positions"]
                                        for(index: String, subjson: JSON) in positions {
                                            if !database.executeUpdate(query, self.ID!, subjson["id"].stringValue, subjson["position_name"].stringValue, subjson["start_date"].stringValue, subjson["end_date"].stringValue, subjson["team"]["id"].stringValue, subjson["team"]["title"].stringValue) {
                                                println("insert positions failed: \(database.lastErrorMessage())")
                                            }
                                        }
                                        self.seemoreLabel.textColor = UIColor.blackColor()
                                        self.seemoreTableCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                        self.seemoreTableCell.userInteractionEnabled = true
                                        
                                        //create programmes' table if not exists
                                        query = "CREATE TABLE IF NOT EXISTS programmes(user_ID INTEGER, programme_ID INTEGER, short_name TEXT)"
                                        if !database.executeUpdate(query) {
                                            println("database programmes create failed:\(database.lastErrorMessage())")
                                        }
                                        
                                        query = "DELETE FROM programmes WHERE user_ID=?"
                                        database.executeUpdate(query, self.ID!)
                                        
                                        //insert into programmes' table
                                        query = "INSERT INTO programmes(user_ID, programme_ID, short_name) VALUES(?,?,?)"
                                        
                                        var programmes = json2["programmes"]
                                        for (index: String, subjson: JSON) in programmes {
                                            if !database.executeUpdate(query, self.ID!, subjson["id"].stringValue, subjson["short_name"].stringValue) {
                                                println("insert programmes failed: \(database.lastErrorMessage())")
                                            }
                                        }
                                        
                                        if let d = database.executeQuery("SELECT * FROM programmes WHERE user_ID=?", self.ID!) {
                                            var array = NSMutableArray()
                                            while d.next() {
                                                array.addObject(d.stringForColumn("programme_ID"))
                                            }
                                            self.programmesDataResource = array
                                            self.programmesCollectionView.reloadData()
                                        }
                                        
                                    } // end if database opened successfully
                                    database.close()
                                    
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
        else if sender as? UITableViewCell == self.seemoreTableCell {
            var dest = segue.destinationViewController as AllPositionsTableViewController
            dest.ID = self.ID
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.programmesDataResource != nil {
            return self.programmesDataResource!.count
        }
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        collectionView.registerNib(UINib(nibName: "ProgrammesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProgrammeCell")
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProgrammeCell", forIndexPath: indexPath) as ProgrammesCollectionViewCell
        
        if let data = self.programmesDataResource {
            var text = data.objectAtIndex(indexPath.row) as String
            
            switch text {
            case "1":
                cell.programmeShortNameLabel.text = "GCDP"
                cell.programmeShortNameLabel.textColor = UIColor.whiteColor()
                cell.programmeShortNameLabel.backgroundColor = UIColor(red: 226.0/255, green: 132.0/255, blue: 93.0/255, alpha: 1.0)
                break
            case "2":
                cell.programmeShortNameLabel.text = "GIP"
                cell.programmeShortNameLabel.textColor = UIColor.whiteColor()
                cell.programmeShortNameLabel.backgroundColor = UIColor(red: 238.0/255, green: 208.0/255, blue: 107.0/255, alpha: 1.0)
                break
            case "3":
                cell.programmeShortNameLabel.text = "TMP"
                cell.programmeShortNameLabel.textColor = UIColor.whiteColor()
                cell.programmeShortNameLabel.backgroundColor = UIColor(red: 167.0/255, green: 217.0/255, blue: 172.0/255, alpha: 1.0)
                break
            case "4":
                cell.programmeShortNameLabel.text = "TLP"
                cell.programmeShortNameLabel.textColor = UIColor.whiteColor()
                cell.programmeShortNameLabel.backgroundColor = UIColor(red: 143.0/255, green: 203.0/255, blue: 214.0/255, alpha: 1.0)
                break
            default:
                break
            } // end of switch
        } // end of if
        return cell
    }
}
