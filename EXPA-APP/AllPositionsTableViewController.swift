//
//  AllPositionsTableViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/14/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit

class AllPositionsTableViewController: UITableViewController {
    
    var ID: String?
    var dataresource: FMResultSet?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // fetch data of positions from sqlite
        let pathOfSQLite = Tools.getFullSubDocumentsPath(subDir: "EXPA.sqlite")
        
        var database = FMDatabase(path: pathOfSQLite)
        
        if !database.open() {
            println("database open failed: \(database.lastErrorMessage())")
        }
        else {
            var query = "SELECT * FROM positions WHERE user_ID=?"
            
            if let data = database.executeQuery(query, self.ID!) {
                self.dataresource = data
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        let pathOfSQLite = Tools.getFullSubDocumentsPath(subDir: "EXPA.sqlite")
        
        var database = FMDatabase(path: pathOfSQLite)
        
        if !database.open() {
            println("database open failed: \(database.lastErrorMessage())")
        }
        else {
            var query = "SELECT COUNT(*) AS number FROM positions WHERE user_ID=?"
            
            if let data = database.executeQuery(query, self.ID!) {
                data.next()
                return data.stringForColumn("number").toInt()!
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerNib(UINib(nibName: "AllPositionsTableViewCell", bundle: nil), forCellReuseIdentifier: "AllPositionsCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("AllPositionsCell", forIndexPath: indexPath) as AllPositionsTableViewCell

        // Configure the cell...
        if dataresource != nil {
            self.dataresource!.next()
            cell.positionNameLabel.text = dataresource!.stringForColumn("position_name")
            cell.teamTitleLabel.text = dataresource!.stringForColumn("team_title")
            if dataresource!.stringForColumn("start_date") != "" && dataresource!.stringForColumn("end_date") != "" {
                cell.startEndDateLabel.text = Tools.oneDateToAnotherDate(oneDate: dataresource!.stringForColumn("start_date"), anotherDate: dataresource!.stringForColumn("end_date"))
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94.0
    }

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
