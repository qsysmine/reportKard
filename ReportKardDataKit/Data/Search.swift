//
//  Search.swift
//  ReportKardDataKit
//
//  Created by Ari Stassinopoulos on 6/14/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation

public enum SearchError: Error {
     case networkError
     case stateError
     case serialisationError
}

public struct SearchData {
    public var results: [SearchResult]
}

public struct SearchResult {
    public var name: String
    public var code: String
}

public class Search {
    static let searchURL = "https://mobile.infinitecampus.com/mobile/searchDistrict?query=%q&state=%s";
    public static func doSearch(districtName: String, districtState: String, withCompletionBlock: @escaping (SearchError?, SearchData?)->Void) {
        let url = searchURL.replacingOccurrences(of: "%q", with: districtName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!).replacingOccurrences(of: "%s", with: districtState);
        if(districtState.characters.count != 2) {
            return withCompletionBlock(.stateError, nil);
        }
        print("doSearch before network");
        Network.doRequest(url: url, cookies: nil) { (data, resp, error) in
            print("doSearch after network");
            self.parseSearch(data, resp, error, withCompletionBlock);
        }
    }
    private static func parseSearch(_ data: Data?, _ resp: URLResponse?, _ error: Error?, _ withCompletionBlock: @escaping (SearchError?, SearchData?) -> Void) {
        if(error != nil) {
            return withCompletionBlock(.networkError, nil);
        }
        if(data == nil) {
            return withCompletionBlock(nil, SearchData(results: [SearchResult]()));
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any],
                let resultsList = json["data"] as? [Any]{
                var results = [SearchResult]();
                for resultDistrict in resultsList {
                    let result = resultDistrict as! [String: Any];
                    let code = result["district_code"] as! String;
                    let name = result["district_name"] as! String;
                    results.append(SearchResult(name: name, code: code));
                }
                withCompletionBlock(nil, SearchData(results: results));
            }
        } catch {
            withCompletionBlock(.serialisationError, nil);
        }
    }
}
