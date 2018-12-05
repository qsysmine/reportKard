//
//  District.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/12/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation

public struct DistrictData {
    public var baseURL: String
    public var appName: String
    public var code: String
    public var name: String?
}

public enum DistrictError: Error {
    case networkError
    case districtNotFoundError
    case deserialisationError
}
public class District {
    //Define checkDistrictURL as a constant
    static let checkDistrictURL = "https://mobile.infinitecampus.com/mobile/checkDistrict?districtCode=%s"
    //Pass district code and get district data
    private static func checkDistrict(districtCode: String, withCompletionBlock: @escaping (DistrictError?, DistrictData?) -> Void) {
        //Check IC website for district code
        Network.doRequest(url: checkDistrictURL.replacingOccurrences(of: "%s", with: districtCode), cookies: nil) { (data, resp, error) in
            //Handle errors
            if(error != nil) {
                return withCompletionBlock(.networkError, nil);
            }
            //String of district content
            let checkDistrictContent = String(data: data!, encoding: String.Encoding.utf8)!;
            if(checkDistrictContent.isEmpty) {
                return withCompletionBlock(DistrictError.districtNotFoundError, nil);
            }
            //Parse JSON from result
            parseDistrict(data: data, districtCode: districtCode, withCompletionBlock: withCompletionBlock);
        }
    }
    private static func parseDistrict(data: Data?, districtCode: String, withCompletionBlock: @escaping (DistrictError?, DistrictData?)->Void) {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                //Assemble DistrictData object with data from parsed JSON
                let districtData = DistrictData(baseURL: json["districtBaseURL"] as! String, appName: json["districtAppName"] as! String, code: districtCode, name: json["districtName"] as? String);
                withCompletionBlock(nil, districtData)
                SavedValues.saveDistrict(districtData);
            }
        } catch {
            //Handle JSON parse errors.
            withCompletionBlock(.deserialisationError, nil)
        }
    }
    //Public facing function
    public static func getDistrict(districtCode: String, withCompletionBlock: @escaping (DistrictError?, DistrictData?)->Void) {
        //Check UserDefaults
        let savedDistrict = SavedValues.savedDistrict();
        if(savedDistrict == nil) {
            return checkDistrict(districtCode: districtCode, withCompletionBlock: withCompletionBlock);
        } else if (savedDistrict!.code != districtCode) {
            return checkDistrict(districtCode: districtCode, withCompletionBlock: withCompletionBlock);
        }
        return withCompletionBlock(nil, savedDistrict!);
    }
}
