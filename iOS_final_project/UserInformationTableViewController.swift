//
//  UserInformationTableViewController.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/4.
//  Copyright © 2019 yochien. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class UserInformationTableViewController: UITableViewController {
    
    var userData : UserData?
    var notificationListData : NotificationListData?

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var notificationFunctionSwitch: UISwitch!
    
    @IBAction func pressPushNotificationToAllAccountButton(_ sender: Any) {
        let alertController = UIAlertController(
            title: "發送推播",
            message: "請輸入推播內容",
            preferredStyle: .alert)
        
        // 建立兩個輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "推播內容"
        }
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[登入]按鈕
        let okAction = UIAlertAction(
            title: "發送",
            style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                let notificationInput =
                    (alertController.textFields?.first)!
                        as UITextField
                
                print("推播內容：\(notificationInput.text)")
                self.sendNotificationToAllAccount(content: notificationInput.text!)

        }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UserData.read() {
            userData = data
            print(userData?.name)
            print(userData?.email)
            print(userData?.facebookID)
            print(userData?.pictureUrl)
            print(userData?.facebookAccessToken)
            let url = URL(string: userData?.pictureUrl ?? "")
            let imageData = try? Data(contentsOf: url!)
            userImage.image = UIImage(data: imageData!)
            userName.text = userData?.name
            userEmail.text = userData?.email
            
            notificationFunctionSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
            self.loadNotificationList()
 
        } else {
            //no user data
            //logout user
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        if(value == true) {
            //switch on
            var counter = 0
            for var i in notificationListData!.data {
                let center = CLLocationCoordinate2D(latitude:  i.data.lat, longitude: i.data.lon)
                let region = CLCircularRegion(center: center, radius: CLLocationDistance(i.data.radius), identifier: String(counter))
                region.notifyOnEntry = true
                region.notifyOnExit = false
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "地理推播", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: i.data.content, arguments: nil)
                content.sound = UNNotificationSound.default()
       
                let request = UNNotificationRequest(identifier: String(counter), content: content, trigger: trigger)
                // Schedule the notification.
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request)
                
                counter += 1
            }
        } else {
            //cancel all notification
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
        }
        // Do something
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
            }
        })
    }
    
    func loadNotificationList() {
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
            } else {
                print("error")
            }
        }
        
        task.resume()
    }
    
    func sendNotificationToAllAccount(content: String) {
        let urlString = "http://140.121.197.197:3000/sendRemoteNotificationToAllAccount?facebook_token="+userData!.facebookAccessToken+"&content="+userData!.name+":"+content
        print(urlString)
        let urlWithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlWithPercentEscapes!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
        }
        
        task.resume()
    }
    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
     */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
