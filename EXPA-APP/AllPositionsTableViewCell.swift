//
//  AllPositionsTableViewCell.swift
//  EXPA-APP
//
//  Created by FanQuan on 1/14/15.
//  Copyright (c) 2015 AIESEC-EXPA. All rights reserved.
//

import UIKit

class AllPositionsTableViewCell: UITableViewCell {

    @IBOutlet weak var positionNameLabel: UILabel!
    @IBOutlet weak var teamTitleLabel: UILabel!
    @IBOutlet weak var startEndDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
