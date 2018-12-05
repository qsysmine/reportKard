//
//  DistrictSearchResultCell.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/15/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit

class DistrictSearchResultCell: UITableViewCell {
    @IBOutlet var districtnameLabel: UILabel!
    @IBOutlet var districtCodeLabel: UILabel!
    var code: String?;
    var superClass: FindDistrictViewController?;
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
        self.addGestureRecognizer(tapGesture);
        super.awakeFromNib()
        // Initialization code
    }
    
    @objc func tapEvent() {
        if(code != nil && superClass != nil) {
            self.superClass!.districtSelected(code!);
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
