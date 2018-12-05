//
//  FindDistrictViewController.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/14/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit
import ReportKardDataKit

class FindDistrictViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    var districtCode = "";
    let states = [ "AK",
                   "AL",
                   "AR",
                   "AS",
                   "AZ",
                   "CA",
                   "CO",
                   "CT",
                   "DC",
                   "DE",
                   "FL",
                   "GA",
                   "GU",
                   "HI",
                   "IA",
                   "ID",
                   "IL",
                   "IN",
                   "KS",
                   "KY",
                   "LA",
                   "MA",
                   "MD",
                   "ME",
                   "MI",
                   "MN",
                   "MO",
                   "MS",
                   "MT",
                   "NC",
                   "ND",
                   "NE",
                   "NH",
                   "NJ",
                   "NM",
                   "NV",
                   "NY",
                   "OH",
                   "OK",
                   "OR",
                   "PA",
                   "PR",
                   "RI",
                   "SC",
                   "SD",
                   "TN",
                   "TX",
                   "UT",
                   "VA",
                   "VI",
                   "VT",
                   "WA",
                   "WI",
                   "WV",
                   "WY"]
    var searchData: SearchData?;
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row];
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchData == nil) {
            return 0;
        }
        return searchData!.results.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "districtSearchResultCell", for: indexPath) as! DistrictSearchResultCell;
        let result = self.searchData!.results[indexPath.row];
        cell.districtnameLabel!.text = result.name;
        cell.districtCodeLabel!.text = result.code;
        cell.code = result.code;
        cell.superClass = self;
        return cell;
    }
    
    let searchURL = "https://mobile.infinitecampus.com/mobile/searchDistrict?query=%q&state=%s";
    
    @IBOutlet var statePicker: UIPickerView!
    @IBOutlet var districtTextField: UITextField!
    @IBOutlet var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self;
        resultsTableView.dataSource = self;
        statePicker.dataSource = self;
        statePicker.delegate = self;
        districtTextField.addTarget(self, action: #selector(search), for: .allEditingEvents);
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.districtTextField!.becomeFirstResponder();
    }
    @objc func search() {
        print("called search");
        let state = states[statePicker.selectedRow(inComponent: 0)];
        let district = districtTextField.text;
        if(district == nil || district! == "" || district!.characters.count <= 4) {
            return;
        }
        Search.doSearch(districtName: district!, districtState: state) {(error, searchData) in
            if(error != nil) {
                return DispatchQueue.main.async {
                    switch error! {
                    case .networkError:
                        return Error.doNonuserError(errorString:  "We had a problem with your network 🙁", vc: self)
                    case .stateError:
                        return Error.doNonuserError(errorString:  "How did you even input that state? 🇺🇸", vc: self)
                    case .serialisationError:
                        return Error.doNonuserError(errorString: "We couldn't deserialise your search results. Sorry!", vc: self)
                    }
                }
            }
            let searchData = searchData!;
            self.searchData = searchData;
            self.perform(#selector(self.reloadData), on: Thread.main, with: nil, waitUntilDone: false);
        };
        
    }
    
    @objc func reloadData() {
        self.resultsTableView.reloadData();
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func districtSelected(_ code: String) {
        self.districtCode = code;
        self.performSegue(withIdentifier: "returnToOnboardingSegue", sender: self);
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier ?? "" == "returnToOnboardingSegue") {
            let destination = segue.destination as? LoginViewController;
            destination?.districtCodeTextField!.text = self.districtCode;
        }
    }
    
}
