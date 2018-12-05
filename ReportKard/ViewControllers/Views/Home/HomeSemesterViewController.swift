//
//  HomeSemesterViewController.swift
//  ReportKard
//
//  Created by Ari Stassinopoulos on 6/17/17.
//  Copyright © 2017 Stassinopoulos. All rights reserved.
//

import UIKit
import ReportKardDataKit

class HomeSemesterViewController: UITableViewController {
    
    var task: ActivitiesTask?;
    var seq: Int?;
    var superView: UIView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(task?.taskSeq)");
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(task == nil) {
            return 0
        }
        return task!.compositeCaterogies!.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(task!.compositeCaterogies![section].compositeActivities == nil) {
            return 0;
        } else {
            return task!.compositeCaterogies![section].compositeActivities!.count;
        }
    }
    
    func load() {
        print(self.task!);
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeSemesterActivityCell", for: indexPath) as! HomeSemesterActivityCell;
        
        let cellData = self.task!.compositeCaterogies![indexPath.section].compositeActivities![indexPath.row];
        let name = cellData.activityName;
        let pointsEarned = cellData.pointsEarned;
        let pointsPossible = cellData.pointsPossible;
        let percentage = cellData.percentage;
        cell.activityNameLabel.text = name;
        let percentageString = "\(percentage ?? 0)%";
        let pointsString = "\(pointsEarned ?? 0)/\(pointsPossible ?? 0)";
        let colour = Colour.colourForPercentage(percentage ?? 0);
        cell.percentageLabel.text = percentageString;
        cell.pointsLabel.text = pointsString;
        cell.gradeView.backgroundColor = colour;
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
