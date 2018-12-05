//
//  LoginViewController.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/15/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit
import ReportKardDataKit

class LoginViewController: UITableViewController {
    
    @IBOutlet var districtCodeTextField: UITextField!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var loginToPass: Login?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator!.isHidden = true;
        loginButton!.isEnabled = false
        
        districtCodeTextField!.addTarget(self, action: #selector(updateButton), for: .allEvents)
        usernameTextField!.addTarget(self, action: #selector(updateButton), for: .allEvents)
        passwordTextField!.addTarget(self, action: #selector(updateButton), for: .allEvents)
        loginButton!.addTarget(self, action: #selector(login), for: .primaryActionTriggered)
    }
    
    @objc func updateButton() {
        let districtCode = districtCodeTextField!.text ?? "";
        let username = usernameTextField!.text ?? "";
        let password = passwordTextField!.text ?? "";
        if(districtCode != "" && username != "" && password != "") {
            loginButton.isEnabled = true;
            return;
        }
        loginButton.isEnabled = false;
    }
    
    @objc func login() {
        let districtCode = districtCodeTextField!.text ?? "";
        let username = usernameTextField!.text ?? "";
        let password = passwordTextField!.text ?? "";
        if(districtCode == "" || username == "" || password == "") {
            return;
        }
        let loginCredentials = ICLogin(username: username, password: password);
        let login = Login(credentials: loginCredentials, districtCode: districtCode)
        self.perform(#selector(self.showActivity), on: .main, with: nil, waitUntilDone: false);
        self.perform(#selector(self.disableLogin), on: .main, with: nil, waitUntilDone: false);
        login.doLogin(withCompletionBlock: { (error, loginStatus) in
            self.perform(#selector(self.hideActivity), on: .main, with: nil, waitUntilDone: false);
            self.perform(#selector(self.enableLogin), on: .main, with: nil, waitUntilDone: false);
            DispatchQueue.main.async {
                if(error != nil) {
                    switch(error!) {
                    case .networkError:
                        return Error.doNonuserError(errorString: "Couldn't log in: Network Error.", vc: self)
                    case .unpackError:
                        return Error.doNonuserError(errorString: "Login returned no result.", vc: self)
                    case .districtError:
                        return Error.doError(errorString: "District does not exist.", dismissButton: "Okay", vc: self)
                    }
                }
                if(loginStatus!.needsCaptcha) {
                    return Error.doError(errorString: "Please log in to a computer and fill out the captcha before trying again.", dismissButton: "I'll fill it out.", vc: self)
                }
                if(!(loginStatus!.approved)) {
                    //self.passwordTextField!.text = "";
                    return Error.doError(errorString: "Incorrect username or password.", dismissButton: "Okay", vc: self)
                }
                if(loginStatus!.approved && loginStatus!.cookies != nil) {
                    DispatchQueue.main.async {
                        SavedValues.saveLogin(loginCredentials);
                        self.loginToPass = login;
                        self.performSegue(withIdentifier: "backHomeSegue", sender: self);
                    }
                }
            };
            
        })
    }
    
    @objc func hideActivity() {
        activityIndicator.isHidden = true;
    }
    
    @objc func showActivity() {
        activityIndicator.isHidden = false;
    }
    
    @objc func enableLogin() {
        loginButton.isEnabled = true;
    }
    
    @objc func disableLogin() {
        loginButton.isEnabled = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "backHomeSegue") {
            let destination = segue.destination as! HomeTableViewController;
            destination.isLoggedIn = true;
            destination.login = self.loginToPass!;
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func unwindToLogin (sender: UIStoryboardSegue){
        
    }
}
