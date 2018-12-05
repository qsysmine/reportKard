//
//  HomeSemesterGradeCell.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/18/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit

class HomeSemesterActivityCell: UITableViewCell {

    @IBOutlet var activityNameLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet var gradeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
