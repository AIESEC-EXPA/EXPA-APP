//
//  IntroductionViewController.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/11/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

    @IBOutlet weak var introductionTextView: UITextView!
    var introductionText: String? //TODO: This property will be replaced by reading data from database or file
    override func viewDidLoad() {
        super.viewDidLoad()
        introductionTextView.text = introductionText
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    
    // MARK: - Navigation
    
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
