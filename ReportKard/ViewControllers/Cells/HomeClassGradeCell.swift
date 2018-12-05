//
//  HomeClassGradeCell.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/16/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit
import ReportKardDataKit

class HomeClassGradeCell: UITableViewCell {
    
    @IBOutlet var classnameLabel: UILabel!
    @IBOutlet var gradeView: UIView!
    @IBOutlet var gradeLabel: UILabel!
    var classObj: OutlineClass?;
    var superView: HomeTableViewController?;
    
    func populateCell(letter: String, percent: Double, className: String, superView: HomeTableViewController, classObj: OutlineClass) {
        self.classObj = classObj;
        self.superView = superView;
        self.classnameLabel.text = className;
        self.gradeLabel.text = "\(letter) (\(percent)%)";
        self.gradeView.backgroundColor = Colour.colourForLetter(letter);
        self.gradeView.layer.cornerRadius = 10;
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
    }
    
    
    @objc func cellTapped() {
        if(self.superView != nil && self.classObj != nil) {
            self.superView!.classTapped(self.classObj!);
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
