//
//  Error.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/15/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation
import UIKit

class Error {
    static func doError(errorString: String, dismissButton: String, vc: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: dismissButton, style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: {
            })
        }
        alertController.addAction(okAction)
        
        vc.present(alertController, animated: true, completion: nil)
    }
    static func doNonuserError(errorString: String, vc: UIViewController) {
        self.doError(errorString: errorString, dismissButton: "I'll try again later.", vc: vc)
    }
}
