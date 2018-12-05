//
//  Activities.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/13/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import Foundation
import SWXMLHash

public enum ActivitiesError: Error {
    case authenticationError
    case networkError
    case downloadError
}

public struct ActivitiesData {
    public var referencedClass: OutlineClass
    public var curve: [ActivitiesCurveItem]
    public var tasks: [ActivitiesTask]
}

public struct ActivitiesTask {
    public var taskID: String
    public var name: String
    public var termName: String
    public var taskSeq: Int
    public var termSeq: Int
    public var termID: String
    public var pointsEarned: Double
    public var pointsPossible: Double
    public var letterGrade: String?
    public var compositeCaterogies: [ActivitiesCategory]?
}
public struct ActivitiesCategory {
    public var activityID: String
    public var name: String
    public var weight: Double
    public var pointsEarned: Double
    public var pointsPossible: Double
    public var percentage: Double
    public var letterGrade: String?
    public var compositeActivities: [ActivitiesActivity]?
}
public struct ActivitiesActivity {
    public var activityID: String
    public var activityName: String
    public var pointsPossible: Double?
    public var pointsEarned: Double?
    public var percentage: Double?
    public var letterGrade: String?
}

public struct ActivitiesCurveItem {
    public var letter: String
    public var minPercent: Double
    public var passing: Bool
}

public class Activities {
    var prism: PrismData,
    district: DistrictData,
    loginStatus: LoginStatus,
    classOutline: OutlineClass;
    
    public init(prism: PrismData, district: DistrictData, loginStatus: LoginStatus, classOutline: OutlineClass) {
        self.prism = prism;
        self.district = district;
        self.loginStatus = loginStatus;
        self.classOutline = classOutline;
    }
    public func getActivities(withCompletionBlock: @escaping (ActivitiesError?, ActivitiesData?)->Void) {
        if(!loginStatus.approved || loginStatus.cookies == nil) {
            return withCompletionBlock(.authenticationError, nil)
        }
        let activitiesURL = URL(string: district.baseURL + "prism?x=portal.PortalOutline&mode=classbook&calendarID=\(prism.schedule.calendarID)&structureID=\(prism.schedule.structureID)&sectionID=\(classOutline.sectionID)&personID=\(prism.student.personID)&x=portal.PortalClassbook")!;
        let request = NSMutableURLRequest(url: activitiesURL);
        request.setValue(loginStatus.cookies!, forHTTPHeaderField: "Cookie");
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36", forHTTPHeaderField: "User-Agent");
        request.setValue("keep-alive", forHTTPHeaderField: "Connection");
        URLSession.shared.dataTask(with: request as URLRequest) { data, resp, error in
            if(error != nil) {
                return withCompletionBlock(.networkError, nil);
            }
            let activitiesContent = String(data: data!, encoding: String.Encoding.utf8);
            if(!(activitiesContent!.contains("campusRoot"))) {
                return withCompletionBlock(.downloadError, nil);
            }
            let xml = SWXMLHash.config {
                config in
                config.shouldProcessLazily = true
                }.parse(data!);
            let curve = [ActivitiesCurveItem]();
            var tasks = [ActivitiesTask]();
            let classbookEl = xml["campusRoot"]["PortalClassbook"]["ClassbookDetail"]["StudentList"]["Student"]["Classbook"];
            let tasksAll = classbookEl["tasks"]["ClassbookTask"].all;
            for taskEl in tasksAll {
                let parsedTask = self.parseTask(taskEl);
                if(parsedTask == nil) {
                    continue;
                }
                tasks.append(parsedTask!);
            }
            let activities = ActivitiesData(referencedClass: self.classOutline, curve: curve, tasks: tasks);
            withCompletionBlock(nil, activities);
            }.resume();
    }
    
    private func parseTask(_ taskEl: XMLIndexer) -> ActivitiesTask?{
        let task = taskEl.element!;
        let taskID = task.attribute(by: "taskID")!.text;
        let name = task.attribute(by: "name")!.text;
        let termName = task.attribute(by: "termName")!.text;
        let taskSeq = Int(task.attribute(by: "taskSeq")!.text) ?? 0;
        let termSeq = Int(task.attribute(by: "termSeq")!.text) ?? 0;
        let termID = task.attribute(by: "termID")!.text;
        let pointsEarned = Double(task.attribute(by: "pointsEarned")!.text) ?? 0;
        let pointsPossible = Double(task.attribute(by: "totalPointsPossible")!.text) ?? 0;
        var letterGrade: String?;
        if(task.attribute(by: "score") != nil) {
            letterGrade = task.attribute(by: "score")!.text;
        }
        let groupsEl = taskEl["groups"];
        if(groupsEl.element == nil) {
            return nil;
        }
        var groups = [ActivitiesCategory]();
        groups = self.parseGroups(groupsEl);
        return ActivitiesTask(taskID: taskID, name: name, termName: termName, taskSeq: taskSeq, termSeq: termSeq, termID: termID, pointsEarned: pointsEarned, pointsPossible: pointsPossible, letterGrade: letterGrade, compositeCaterogies: groups);
    }
    
    private func parseGroups(_ groupsEl: XMLIndexer) -> [ActivitiesCategory] {
        let classbookGroups = groupsEl["ClassbookGroup"];
        var groups = [ActivitiesCategory]();
        for classbookGroupEl in classbookGroups.all {
            groups.append(parseGroup(classbookGroupEl))
        }
        return groups;
    }
    
    private func parseGroup(_ classbookGroupEl: XMLIndexer) -> ActivitiesCategory {
        let classbookGroup = classbookGroupEl.element!;
        let activityID = (classbookGroup.attribute(by: "activityID") != nil ? classbookGroup.attribute(by: "activityID")!.text : "");
        let name = (classbookGroup.attribute(by: "activityID") != nil ? classbookGroup.attribute(by: "name")!.text : "");
        let weight = Double(classbookGroup.attribute(by: "weight")!.text) ?? 1.0;
        let pointsEarned = Double(classbookGroup.attribute(by: "pointsEarned")!.text) ?? 0;
        let pointsPossible = Double(classbookGroup.attribute(by: "totalPointsPossible")!.text) ?? 0;
        let percentage = Double(classbookGroup.attribute(by: "percentage")!.text) ?? 0;
        let letterGrade = (classbookGroup.attribute(by: "letterGrade") != nil ? classbookGroup.attribute(by: "letterGrade")!.text : "");
        let acts = classbookGroupEl["activities"]["ClassbookActivity"].all;
        let compositeActivities = parseActivities(acts);
        let group = ActivitiesCategory(activityID: activityID, name: name, weight: weight, pointsEarned: pointsEarned, pointsPossible: pointsPossible, percentage: percentage, letterGrade: letterGrade, compositeActivities: compositeActivities);
        return group;
    }
    
    private func parseActivities(_ acts: [XMLIndexer]) -> [ActivitiesActivity] {
        var activitiesToReturn = [ActivitiesActivity]();
        for actEl in acts {
            activitiesToReturn.append(parseActivity(actEl));
        }
        return activitiesToReturn;
    }
    
    private func parseActivity(_ actEl: XMLIndexer) -> ActivitiesActivity {
        let el = actEl.element!;
        let activityID = (el.attribute(by: "activityID") != nil ? el.attribute(by: "activityID")!.text : "");
        let activityName = el.attribute(by: "name")!.text;
        let isGraded = !(Bool(el.attribute(by: "notGraded")!.text) ?? true);
        let validScore = Bool(el.attribute(by: "validScore")!.text) ?? false;
        if(isGraded && validScore) {
            return assembleActivity(el, activityID, activityName);
        } else {
            return ActivitiesActivity(activityID: activityID, activityName: activityName, pointsPossible: nil, pointsEarned: nil, percentage: nil, letterGrade: nil);
        }
    }
    
    private func assembleActivity(_ el: XMLElement, _ activityID: String, _ activityName: String) -> ActivitiesActivity {
        let pointsEarned = Double(el.attribute(by: "weightedScore")!.text) ?? 0;
        let pointsPossible = Double(el.attribute(by: "weightedTotalPoints")!.text) ?? 0;
        let percentage = Double(el.attribute(by: "weightedPercentage")!.text) ?? 0;
        var letterGrade = "";
        if(el.attribute(by: "score") != nil) {
            letterGrade = el.attribute(by: "score")!.text;
        }
        return ActivitiesActivity(activityID: activityID, activityName: activityName, pointsPossible: pointsPossible, pointsEarned: pointsEarned, percentage: percentage, letterGrade: letterGrade);
    }
}
