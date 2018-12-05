//
//  Network.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/12/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation

public class Network {
    public static func doRequest(url: String, cookies: String?, withCompletionBlock: @escaping (Data?, URLResponse?, Error?)->Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!);
        if(cookies != nil) {
            request.setValue(cookies!, forHTTPHeaderField: "Cookie");
        }
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36", forHTTPHeaderField: "User-Agent");
        request.setValue("keep-alive", forHTTPHeaderField: "Connection");
        URLSession.shared.dataTask(with: request as URLRequest) { data, resp, error in
            withCompletionBlock(data, resp, error);
        }.resume();
    }
}
