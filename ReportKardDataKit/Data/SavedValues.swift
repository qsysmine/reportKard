//
//  SavedValues.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/12/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation
import KeychainSwift

public enum SavedKeys: String {
    case savedDistrictKey = "RK-savedDistrict"
    case savedUsernameKey = "RK-savedUsername"
    case savedPrismKey = "RK-savedPrism"
}

public class SavedValues {
    static let suiteName = "group.com.Stassinopoulos.ari.reportKardGroup"
    static func getDefaults() -> UserDefaults {
        let userDefaults = UserDefaults(suiteName: SavedValues.suiteName);
        if(userDefaults != nil) {
            return userDefaults!;
        } else {
            return UserDefaults.standard;
        }
    }
    public static func savedPrism() -> PrismData? {
        let savedPrism = getDefaults().value(forKey: SavedKeys.savedPrismKey.rawValue);
        if(savedPrism == nil) {
            return nil;
        }
        let data = savedPrism as! [String:String];
        return PrismData(student: PrismStudent(name: data["studentName"]!, studentNumber: data["studentNumber"]!, personID: data["personID"]!), schedule: PrismSchedule(structureID: data["structureID"]!, calendarName: data["calendarName"]!, calendarID: data["calendarID"]!));
    }
    public static func savePrism(prism: PrismData) {
        let schedule = prism.schedule;
        let student = prism.student;
        let serialised: [String: String] = ["calendarID": schedule.calendarID,
                                            "calendarName": schedule.calendarName,
                                            "structureID": schedule.structureID,
                                            "studentName": student.name,
                                            "personID": student.personID,
                                            "studentNumber": student.studentNumber];
        return getDefaults().set(serialised, forKey: SavedKeys.savedPrismKey.rawValue);
    }
    public static func savedDistrict() -> DistrictData? {
        let savedDistrict = getDefaults().value(forKey: SavedKeys.savedDistrictKey.rawValue);
        if(savedDistrict == nil) {
            return nil;
        } else {
            let data = savedDistrict as! [String:String];
            return DistrictData(baseURL: data["baseURL"]!, appName: data["appName"]!, code: data["code"]!, name: data["name"]!);
        }
    }
    public static func saveDistrict(_ districtData: DistrictData) {
        let baseURL = districtData.baseURL;
        let appName = districtData.appName;
        let code = districtData.code;
        let name = districtData.name!;
        let serialised: [String:String] = ["baseURL":baseURL, "appName":appName,"code":code,"name":name];
        return getDefaults().set(serialised, forKey: SavedKeys.savedDistrictKey.rawValue)
    }
    public static func savedLogin() -> ICLogin? {
        let username = getDefaults().value(forKey: SavedKeys.savedUsernameKey.rawValue) as! String;
        let password = (KeychainSwift().get("RK-savedPassword") ?? "");
        if(password == "") {
            return nil;
        }
        return ICLogin(username: username, password: password);
    }
    public static func saveLogin(_ login: ICLogin) {
        let username = login.username;
        let password = login.password;
        getDefaults().set(username, forKey: SavedKeys.savedUsernameKey.rawValue);
        KeychainSwift().set(password, forKey: "RK-savedPassword");
    }
}
