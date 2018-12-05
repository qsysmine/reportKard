//
//  HomeClassGradesViewController.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/17/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit
import ReportKardDataKit

class HomeClassGradesViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var classObj: OutlineClass?;
    var activitiesObject: ActivitiesData?;
    var prismObj: PrismData?;
    var loginStatusObj: LoginStatus?;
    
    var pageNum = 0;
    var pageControllers = [UIViewController]();
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if(pageNum-1 < 0) {
            return nil;
        } else {
            pageNum -= 1;
            return pageControllers[pageNum];
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if(pageNum+1 >= pageControllers.count) {
            return nil;
        } else {
            pageNum += 1;
            return pageControllers[pageNum];
        }
    }
    
    var classToParse: OutlineClass?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        dataSource = self;
        delegate = self;
        print("view loaded");
        self.pageControllers = [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeActivitiesLoadingViewController")];
        print("page controller defined");
        self.setViewControllers(self.pageControllers , direction: .forward, animated: true) { (completion) in
            print(completion);
        }
        
        let activity = Activities(prism: prismObj!, district: SavedValues.savedDistrict()!, loginStatus: self.loginStatusObj!, classOutline: self.classObj!)
        activity.getActivities { (error, data) in
            if(error != nil) {
                return DispatchQueue.main.async {
                    switch(error!) {
                    case .authenticationError:
                        self.performSegue(withIdentifier: "backHomeFromClassSegue", sender: self);
                        Error.doNonuserError(errorString: "Error: Authentication Error", vc: self.pageControllers[self.pageNum]);
                    case .networkError:
                        self.performSegue(withIdentifier: "backHomeFromClassSegue", sender: self);
                        Error.doNonuserError(errorString: "Error: Network Error", vc: self.pageControllers[self.pageNum]);
                    case .downloadError:
                        self.performSegue(withIdentifier: "backHomeFromClassSegue", sender: self);
                        Error.doNonuserError(errorString: "Error: Download Error", vc: self.pageControllers[self.pageNum]);
                    }
                }
            }
            self.activitiesObject = data!;
            self.setup();
        }
    }
    
    func setup() {
        let data = self.activitiesObject!;
        var filteredTasks = [ActivitiesTask]();
        data.tasks.forEach { (task) in
            if(task.compositeCaterogies == nil || task.compositeCaterogies!.count == 0) {
                return;
            }
            filteredTasks.append(task);
        }
        filteredTasks.sort { (a, b) -> Bool in
            if(a.termSeq == b.termSeq) {
                return a.taskSeq > b.taskSeq;
            }
            return a.termSeq > b.termSeq;
        }
        self.pageControllers = [];
        filteredTasks.forEach { (task) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeSemesterViewController") as? HomeSemesterViewController;
            vc?.superView = self.view;
            vc?.task = task;
            vc?.load();
            self.pageControllers.append(vc!);
        }
        let initialViewController = self.pageControllers[0];
        DispatchQueue.main.async {
            self.setViewControllers([initialViewController], direction: .forward, animated: true) { (completion) in
                print(completion);
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
