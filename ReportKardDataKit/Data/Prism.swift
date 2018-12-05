//
//  Prism.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/13/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation
import SWXMLHash

public enum PrismError: Error {
    case couldNotConstructStudentError
    case authenticationError
    case downloadError
}

public struct PrismStudent {
    public var name: String
    public var studentNumber: String
    public var personID: String
}

public struct PrismSchedule {
    public var structureID: String
    public var calendarName: String
    public var calendarID: String
}

public struct PrismData {
    public var student: PrismStudent
    public var schedule: PrismSchedule
}

public class Prism {
    var loginStatus: LoginStatus;
    var district: DistrictData;
    
    public init(loginStatus: LoginStatus, district: DistrictData) {
        self.district = district;
        self.loginStatus = loginStatus;
    }
    
    public func getPrism(withCompletionBlock: @escaping (PrismError?, PrismData?)->Void) {
        if(!loginStatus.approved || loginStatus.cookies == nil) {
            return withCompletionBlock(PrismError.authenticationError, nil);
        }
        let baseURL = district.baseURL;
        let appName = district.appName;
        let prismURL = "\(baseURL)prism?x=portal.PortalOutline&appName=\(appName)";
        print(prismURL);
        Network.doRequest(url: prismURL, cookies: loginStatus.cookies!) { (data, resp, error) in
            self.parseResponse(data, resp, error, withCompletionBlock: withCompletionBlock);
        }
    }
    
    private func parseResponse(_ data: Data?, _ resp: URLResponse?, _ error: Error?, withCompletionBlock: @escaping (PrismError?, PrismData?)->Void) {
        if(error != nil) {
            print(error);
            return withCompletionBlock(PrismError.downloadError, nil);
        }
        let prismContent = String(data: data!, encoding: String.Encoding.utf8);
        if(!(prismContent!.contains("campusRoot"))) {
            return withCompletionBlock(PrismError.downloadError, nil);
        }
        self.parsePrism(data, withCompletionBlock:withCompletionBlock);
    }
    
    private func parsePrism(_ data: Data?, withCompletionBlock: @escaping (PrismError?, PrismData?) -> Void) {
        let xml = SWXMLHash.config {
            config in
            config.shouldProcessLazily = true
            }.parse(data!);
        let portalOutline = xml["campusRoot"]["PortalOutline"];
        let family = portalOutline["Family"];
        let student = family["Student"].element!;
        let studentToReturn = parseStudentElement(student);
        if(studentToReturn == nil) {
            return withCompletionBlock(PrismError.couldNotConstructStudentError, nil);
        }
        let scheduleStructure = xml["campusRoot"]["PortalOutline"]["Family"]["Student"]["Calendar"]["ScheduleStructure"].element!;
        let scheduleStructureID = scheduleStructure.attribute(by: "structureID")!.text;
        let scheduleCalendarName = scheduleStructure.attribute(by: "calendarName")!.text;
        let scheduleCalendarID = scheduleStructure.attribute(by: "calendarID")!.text;
        let scheduleToReturn = PrismSchedule(structureID: scheduleStructureID, calendarName: scheduleCalendarName, calendarID: scheduleCalendarID);
        return withCompletionBlock(nil, PrismData(student: studentToReturn!, schedule: scheduleToReturn));
    }
    
    private func parseStudentElement(_ student: XMLElement) -> PrismStudent?{
        do {
            if let studentNumber = student.attribute(by: "studentNumber"),
                let studentFirstName = student.attribute(by: "firstName"),
                let studentLastName = student.attribute(by: "lastName"),
                let studentPersonID = student.attribute(by: "personID") {
                let studentName = [studentFirstName.text, studentLastName.text].joined(separator: " ");
                return PrismStudent(name: studentName, studentNumber: studentNumber.text, personID: studentPersonID.text);
            } else {
                throw PrismError.couldNotConstructStudentError;
            }
        } catch {
            return nil;
        }
    }
}
