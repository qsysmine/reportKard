//
//  Outline.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/13/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation
import SWXMLHash

public enum OutlineError: Error {
    case networkError
    case authenticationError
    case downloadError
}

public struct OutlineData {
    public var classes: [OutlineClass]
}

public struct OutlineClass {
    public var name: String
    public var teacherName: String
    public var grades: [OutlineClassGrade]
    public var structureID: String
    public var sectionID: String
    public var calendarID: String
}

public struct OutlineClassGrade {
    public var name: String
    public var scores: [OutlineClassScore]
    public var seq: Int
}

public struct OutlineClassScore {
    public var name: String
    public var seq: Int
    public var letter: String
    public var percent: Double
    public var timeStamp: String
}

public class Outline {
    var prism: PrismData;
    var district: DistrictData;
    var loginStatus: LoginStatus;
    
    public init(prism: PrismData, district: DistrictData, loginStatus: LoginStatus) {
        self.prism = prism;
        self.district = district;
        self.loginStatus = loginStatus;
    }
    
    public func getOutline(withCompletionBlock: @escaping (OutlineError?, OutlineData?) -> Void) {
        if(!loginStatus.approved || loginStatus.cookies == nil) {
            return withCompletionBlock(.authenticationError, nil)
        }
        let classbookURL = "\(district.baseURL)prism?&x=portal.PortalClassbook-getClassbookForAllSections&mode=classbook&personID=\(prism.student.personID)&structureID=\(prism.schedule.structureID)&calendarID=\(prism.schedule.calendarID)";
        Network.doRequest(url: classbookURL, cookies: loginStatus.cookies) { (data, resp, error) in
            if(error != nil || data == nil || resp == nil) {
                return withCompletionBlock(.networkError, nil);
            }
            self.parseClassbook(data, withCompletionBlock: withCompletionBlock);
        }
    }
    private func parseClassbook(_ data: Data?, withCompletionBlock: @escaping (OutlineError?, OutlineData?) -> Void) {
        let classbookContent = String(data: data!, encoding: String.Encoding.utf8);
        if(!(classbookContent!.contains("campusRoot"))) {
            return withCompletionBlock(.downloadError, nil);
        }
        let xml = SWXMLHash.config {
            config in
            config.shouldProcessLazily = true
            }.parse(data!);
        let classes = xml["campusRoot"]["SectionClassbooks"]["PortalClassbook"];
        var classesToReturn = [OutlineClass]();
        for classElem in classes.all {
            let computedClass = computeClass(classElem);
            if(computedClass == nil) {continue;}
            classesToReturn.append(computedClass!);
        }
        withCompletionBlock(nil, OutlineData(classes: classesToReturn));
    }
    private func computeClass(_ classElem: XMLIndexer) -> OutlineClass? {
        let course = classElem["Section"]["Course"].element!;
        let courseName = course.attribute(by:"name")!.text;
        let student = classElem["StudentList"]["Student"];
        let gradingDetailSummary = student["GradingDetailSummary"];
        if(gradingDetailSummary.element == nil) {
            return nil;
        }
        let gradingSection = gradingDetailSummary["Section"];
        let teacherName = gradingSection.element!.attribute(by: "teacherDisplay")!.text;
        let sectionID = gradingSection.element!.attribute(by: "sectionID")!.text;
        let tasks = gradingSection["Task"];
        var grades = [OutlineClassGrade]();
        for taskElem in tasks.all {
            grades.append(self.computeTask(taskElem));
        }
        return OutlineClass(name: courseName, teacherName: teacherName, grades: grades, structureID: self.prism.schedule.structureID, sectionID: sectionID, calendarID: self.prism.schedule.calendarID);
    }
    private func computeTask(_ taskElem: XMLIndexer)->OutlineClassGrade {
        let taskName = taskElem.element!.attribute(by: "name")!.text;
        let taskSeq = taskElem.element!.attribute(by: "seq")!.text;
        let scores = taskElem["Score"];
        var outlineScores = [OutlineClassScore]();
        for scoreElem in scores.all {
            let computedScore = computeScore(scoreElem);
            if(computedScore == nil) {continue;}
            outlineScores.append(computedScore!);
        }
        return OutlineClassGrade(name: taskName, scores: outlineScores, seq: Int(taskSeq)!);
    }
    
    private func computeScore(_ scoreElem: XMLIndexer) -> OutlineClassScore? {
        let score = scoreElem.element!
        let scoreName = score.attribute(by: "termName")!.text;
        let scoreSeq = score.attribute(by: "termSeq")!.text;
        let scoreLetterA = score.attribute(by: "score");
        let scorePercentA = score.attribute(by: "percent");
        let scoreTimeStampA = score.attribute(by: "date");
        if(scoreLetterA == nil || scorePercentA == nil || scoreTimeStampA == nil) {
            return nil;
        }
        let scoreLetter = score.attribute(by: "score")!.text;
        let scorePercent = score.attribute(by: "percent")!.text;
        let scoreTimeStamp = score.attribute(by: "date")!.text;
        return OutlineClassScore(name: scoreName, seq: Int(scoreSeq)!, letter: scoreLetter, percent: Double(scorePercent)!, timeStamp: scoreTimeStamp);
    }
}

