//
//  HomeTableViewController.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/14/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit
import ReportKardDataKit

class HomeTableViewController: UITableViewController {
    var isLoggedIn = false;
    var wasOnboarding = false;
    var login: Login?;
    var loginStatus: LoginStatus?;
    var data: OutlineData?;
    var goToClass: OutlineClass?;
    var prism: PrismData?;
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoggedIn = (SavedValues.savedDistrict() != nil && SavedValues.savedLogin() != nil);
        if(!isLoggedIn) {
            wasOnboarding = true;
            return self.performSegue(withIdentifier: "onboardSegue", sender: self);
        }
        let hasPrism = SavedValues.savedPrism() != nil;
        if(hasPrism) {
            self.prism = SavedValues.savedPrism()!;
            return self.checkLogin(hasPrism);
        }
        self.checkLogin(false);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func checkLogin(_ hasPrism: Bool) {
        self.login = Login(credentials: SavedValues.savedLogin()!, districtCode: SavedValues.savedDistrict()!.code)
        print("logging in");
        self.login?.doLogin(withCompletionBlock: { (error, loginStatus) in
            print("got callback");
            if(error != nil) {
                return DispatchQueue.main.async {
                    switch error! {
                    case .networkError:
                        Error.doNonuserError(errorString: "Network Error", vc: self)
                    case .unpackError:
                        Error.doNonuserError(errorString: "Couldn't Unpack Login", vc: self)
                    case .districtError:
                        Error.doNonuserError(errorString: "District Error", vc: self);
                    }
                }
            }
            if(loginStatus!.approved) {
                self.loginStatus = loginStatus!;
                print("Ready");
                return self.load(hasPrism);
            } else if(loginStatus!.needsCaptcha) {
                return DispatchQueue.main.async {
                    Error.doError(errorString: "Captcha required: Please log into Infinite Campus from a computer and fill out the Captcha.", dismissButton: "Got it.", vc: self)
                }
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!isLoggedIn) {
            wasOnboarding = true;
            return self.performSegue(withIdentifier: "onboardSegue", sender: self);
        }
        if(wasOnboarding) {
            wasOnboarding = true;
            self.checkLogin(false);
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(self.data == nil) {
            return 0;
        }
        return self.data!.classes.count;
    }
    
    func load(_ hasPrism: Bool) {
        let loginStatus = self.loginStatus!;
        let district = SavedValues.savedDistrict()!;
        let prism = Prism(loginStatus: loginStatus, district: district);
        print("Loading");
        if(!hasPrism) {
            return prism.getPrism { (error, prismData) in
                print("Prism Callback");
                if(error != nil) {
                    return DispatchQueue.main.async {
                        switch error! {
                        case .couldNotConstructStudentError:
                            Error.doNonuserError(errorString: "Prism Error: Could not construct student.", vc: self)
                        case .authenticationError:
                            self.performSegue(withIdentifier: "onboardSegue", sender: self)
                        case .downloadError:
                            Error.doNonuserError(errorString: "Prism Error: Could not download Prism.", vc: self)
                        }
                    }
                }
                SavedValues.savePrism(prism: prismData!);
                self.prism = prismData;
                self.load(true);
            }
        }
        let outline = Outline(prism: self.prism!, district: district, loginStatus: loginStatus);
        print("Getting outline");
        outline.getOutline { (error, outlineData) in
            print("Outline callback");
            if(error != nil) {
                return DispatchQueue.main.async {
                    switch(error!) {
                    case .networkError:
                        Error.doNonuserError(errorString: "Outline Error: Network error", vc: self)
                    case .authenticationError:
                        self.performSegue(withIdentifier: "onboardSegue", sender: self);
                    case .downloadError:
                        Error.doNonuserError(errorString: "Outline Error: Could not download outline", vc: self);
                    }
                }
            }
            let data = outlineData!;
            self.data = data;
            return DispatchQueue.main.async {
                self.tableView!.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeClassGradeCell", for: indexPath) as! HomeClassGradeCell;
        let data = self.data!.classes[indexPath.row];
        let className = data.name;
        let grades = data.grades;
        print(grades);
        let sortedGrades = grades.sorted { (a, b) -> Bool in
            if(a.scores.count == 0) { return false; }
            if(b.scores.count == 0) { return true; }
            return a.seq > b.seq;
        };
        let mostRecentGrade = sortedGrades[0];
        let scores = mostRecentGrade.scores;
        let sortedScores = scores.sorted { (a,b) -> Bool in
            
            return a.seq > b.seq
        };
        if(sortedScores.count > 0) {
        let mostRecentScore = sortedScores[0];
        let letter = mostRecentScore.letter
        let percent = mostRecentScore.percent;
        cell.populateCell(letter: letter, percent: percent, className: className, superView: self, classObj: data);
        } else {
            cell.populateCell(letter: "", percent: 0.0, className: className, superView: self, classObj: data)
        }
        return cell
    }
    
    func classTapped(_ classObj: OutlineClass) {
        self.goToClass = classObj;
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showClassSegue", sender: self)
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showClassSegue") {
            let destination = segue.destination as! HomeClassGradesViewController;
            destination.classObj = self.goToClass!;
            destination.loginStatusObj = self.loginStatus!;
            destination.prismObj = self.prism!;
        }
    }
    
    @IBAction func unwindToHome (sender: UIStoryboardSegue){
        
    }
}
