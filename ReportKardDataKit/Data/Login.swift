//
//  Login.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/12/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation

public struct ICLogin {
    public var username: String
    public var password: String
    public init(username: String, password: String) {
        self.username = username;
        self.password = password;
    }
}

public struct LoginStatus {
    public var approved: Bool
    public var needsCaptcha: Bool
    public var cookies: String?
}

public enum LoginError: Error {
    case networkError
    case unpackError
    case districtError
}

public class Login {
    public var status: LoginStatus?;
    var credentials: ICLogin;
    var districtCode: String;
    var cookies: String? {
        if(status != nil) {
            return status!.cookies;
        } else {
            return nil;
        }
    }
    
    public init(credentials: ICLogin, districtCode: String) {
        self.credentials = credentials;
        self.districtCode = districtCode;
    }
    
    public func doLogin(withCompletionBlock: @escaping (LoginError?, LoginStatus?)->Void) {
        District.getDistrict(districtCode: self.districtCode) { (error, district) in
            if(error != nil) {
                return withCompletionBlock(LoginError.districtError, nil);
            }
            let baseURL = district!.baseURL;
            let loginURL = "\(baseURL)verify.jsp?nonBrowser=true&username=\(self.credentials.username)&password=\(self.credentials.password)&appName=\(district!.appName)";
            Network.doRequest(url: loginURL, cookies: nil, withCompletionBlock: { (data, resp, error) in
                self.parseResponse(data: data, resp: resp, error: error, withCompletionBlock: withCompletionBlock)
            })
        }
    }
    private func parseResponse(data: Data?, resp: URLResponse?, error: Error?, withCompletionBlock: @escaping (LoginError?, LoginStatus?)->Void) {
        if(error != nil) {
            return withCompletionBlock(LoginError.networkError, nil);
        } else if(data == nil) {
            return withCompletionBlock(LoginError.networkError, nil);
        }
        let loginBody = String(data: data!, encoding: String.Encoding.utf8);
        if(loginBody == nil || resp == nil) {
            return withCompletionBlock(LoginError.unpackError, nil);
        }
        self.parseLogin(loginBody!, resp!, withCompletionBlock: withCompletionBlock);
    }
    
    private func parseLogin(_ loginBody: String, _ resp: URLResponse, withCompletionBlock: (LoginError?, LoginStatus?)->Void) {
        var loginApproved = false;
        var loginRequiresCaptcha = false;
        var loginCookies: String?;
        if(loginBody.contains("success")) {
            loginApproved = true;
            loginCookies = (resp as! HTTPURLResponse).allHeaderFields["Set-Cookie"] as? String;
        } else if(loginBody.contains("captcha")) {
            loginRequiresCaptcha = false;
        }
        let status = LoginStatus(approved: loginApproved, needsCaptcha: loginRequiresCaptcha, cookies: loginCookies);
        self.status = status;
        print(self.status!);
        return withCompletionBlock(nil, status);
    }
    
    public func checkLogin(withCompletionBlock: @escaping (Bool)->Void){
        if(self.status == nil) {
            return withCompletionBlock(false);
        }
        if(self.status!.cookies == nil) {
            return withCompletionBlock(false);
        }
        District.getDistrict(districtCode: self.districtCode) { (error, districtData) in
            if(error != nil || districtData == nil) {
                return withCompletionBlock(false);
            }
            let baseURL = districtData!.baseURL;
            let appName = districtData!.appName;
            let checkURL = "\(baseURL)prism?x=portal.PortalOutline&appName=\(appName)";
            Network.doRequest(url: checkURL, cookies: self.status!.cookies) { (data, resp, error) in
                if(error != nil) {
                    return withCompletionBlock(false);
                } else if("\(resp!.url!)".contains("noAppName")) {
                    return withCompletionBlock(false);
                }
                return withCompletionBlock(true);
            }
        }
    }
}
