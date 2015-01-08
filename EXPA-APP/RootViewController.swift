//
//  RootViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/8/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit

class RootViewController: RESideMenu {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.backgroundImage = UIImage(named: "SideMenuBackground.jpg")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        //self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
        //self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuController"];
        //self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"rightMenuController"];
        self.leftMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("leftViewController") as UIViewController
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationControllerForMainView") as UIViewController
        self.rightMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("rightViewController") as UIViewController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
