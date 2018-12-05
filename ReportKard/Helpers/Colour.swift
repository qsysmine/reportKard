//
//  Colour.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/18/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation
import UIKit

class Colour {
    static let letterScores: [String: Double] = [
        "A+": 4.5,
        "A": 4.0,
        "A-": 3.75,
        "B+": 3.5,
        "B": 3,
        "B-": 2.75,
        "C+": 2.5,
        "C": 2,
        "C-": 1.75,
        "D+": 1.5,
        "D": 1,
        "D-": 0.75,
        "F": 0.5
    ];
    static func colourForLetter(_ letter: String) -> UIColor {
        let score = letterScores[letter] ?? 4.0;
        let green = score / 4.5;
        let red = 1 - green;
        let blue = 0;
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0);
    }
    static func colourForPercentage(_ percentage: Double) -> UIColor {
        var green = percentage / 100;
        var red = 1 - green;
        let blue = 0;
        if(percentage > 100) {
            red = 0;
            green = 1;
        }
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0);
    }
}
