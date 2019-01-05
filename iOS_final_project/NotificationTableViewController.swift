//
//  NotificationTableViewController.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/5.
//  Copyright © 2019 yochien. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
    
    var userData : UserData?
    var notificationListData : NotificationListData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let data = UserData.read() {
            userData = data
            
        } else {
            //no user data
            //logout user
            
        }
        
        let url = URL(string: "http://140.121.197.197:3000/getUserNotificationList?facebook_token="+userData!.facebookAccessToken)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let data = data, let results = try?
                decoder.decode(NotificationListData.self, from: data)
            {
                print("json load success")
                print(results)
                self.notificationListData = results
                self.tableView.reloadData()
            } else {
                print("error")
            }
        }
        
        task.resume()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let notificationNum = self.notificationListData?.data.count {
            print("count",notificationNum)
            return notificationNum
        } else {
            print("count nil")
            return 0
        }
        
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let notificationNum = self.notificationListData?.data.count {
            print("count",notificationNum)
            return notificationNum
        } else {
            print("count nil")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        // Configure the cell...
        if let notification = notificationListData?.data[indexPath.row]{
            
            cell.lat.text = String(format: "%.4f", notification.data.lat)
            cell.lon.text = String(format: "%.4f", notification.data.lon)
            cell.radius.text = String(notification.data.radius) + "公尺"
            cell.time.text = notification.data.time
        }
        print("cell-",cell)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
